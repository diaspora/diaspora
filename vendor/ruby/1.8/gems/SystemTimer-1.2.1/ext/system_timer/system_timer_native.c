/*
 * SystemTimer native implementation relying on ITIMER_REAL
 * 
 * Copyright 2008 David Vollbracht & Philippe Hanrigou
 */
 
#include "ruby.h"
#include "rubysig.h"
#include <signal.h>
#include <errno.h>
#include <stdarg.h>

#define DISPLAY_ERRNO 	 		 1
#define DO_NOT_DISPLAY_ERRNO 0
#define MICRO_SECONDS 1000000.0
#define MINIMUM_TIMER_INTERVAL_IN_SECONDS 0.2

VALUE rb_cSystemTimer;

// Ignore most of this for Rubinius
#ifndef RUBINIUS

sigset_t original_mask;
sigset_t sigalarm_mask;
struct sigaction original_signal_handler;
struct itimerval original_timer_interval;
static int debug_enabled = 0;

static void clear_pending_sigalrm_for_ruby_threads();
static void install_ruby_sigalrm_handler(VALUE);
static void restore_original_ruby_sigalrm_handler(VALUE);
static void restore_original_sigalrm_mask_when_blocked();
static void restore_original_timer_interval();
static void set_itimerval_with_minimum_1s_interval(struct itimerval *, VALUE);
static void set_itimerval(struct itimerval *, double);
static void restore_sigalrm_mask(sigset_t *previous_mask);
static void log_debug(char*, ...);
static void log_error(char*, int);


static VALUE install_first_timer_and_save_original_configuration(VALUE self, VALUE seconds)
{
    struct itimerval timer_interval;

    if (debug_enabled) {
        log_debug("[install_first_timer] %.2lfs\n", NUM2DBL(seconds));
    }

    /*
     * Block SIG_ALRM for safe processing of SIG_ALRM configuration and save mask.
     */
    if (0 != sigprocmask(SIG_BLOCK, &sigalarm_mask, &original_mask)) {
        log_error("[install_first_timer] Could not block SIG_ALRM\n", DISPLAY_ERRNO);
        return Qnil;
    }
    clear_pending_sigalrm_for_ruby_threads();
    log_debug("[install_first_timer] Successfully blocked SIG_ALRM at O.S. level\n");
	
   /*
    * Save previous signal handler.
    */
    log_debug("[install_first_timer] Saving original system handler\n");
    original_signal_handler.sa_handler = NULL;
    if (0 != sigaction(SIGALRM, NULL, &original_signal_handler)) {
        log_error("[install_first_timer] Could not save existing handler for SIG_ALRM\n", DISPLAY_ERRNO);
        restore_original_sigalrm_mask_when_blocked();
        return Qnil;
    }
    log_debug("[install_first_timer] Successfully saved existing SIG_ALRM handler\n");
    
	 /*
	  * Install Ruby Level SIG_ALRM handler
	  */
    install_ruby_sigalrm_handler(self);

    /*
     * Save original real time interval timer and aet new real time interval timer.     
     */	
    set_itimerval(&original_timer_interval, 0.0);
    set_itimerval_with_minimum_1s_interval(&timer_interval, seconds);
    if (0 != setitimer(ITIMER_REAL, &timer_interval, &original_timer_interval)) {
        log_error("[install_first_timer] Could not install our own timer, timeout will not work", DISPLAY_ERRNO);
        restore_original_ruby_sigalrm_handler(self);
        restore_original_sigalrm_mask_when_blocked();
        return Qnil;
    }
    if (debug_enabled) {
      log_debug("[install_first_timer] Successfully installed timer (%ds)\n", 
                timer_interval.it_value.tv_sec);
    }

    /*
     * Unblock SIG_ALRM
     */
    if (0 != sigprocmask(SIG_UNBLOCK, &sigalarm_mask, NULL)) {
        log_error("[install_first_timer] Could not unblock SIG_ALRM, timeout will not work", DISPLAY_ERRNO);
        restore_original_timer_interval();
        restore_original_ruby_sigalrm_handler(self);
        restore_original_sigalrm_mask_when_blocked();		
    }
    log_debug("[install_first_timer] Successfully unblocked SIG_ALRM.\n");

    return Qnil;
}

static VALUE install_next_timer(VALUE self, VALUE seconds)
{
    struct itimerval timer_interval;
    sigset_t previous_sigalarm_mask;

    if (debug_enabled) {
        log_debug("[install_next_timer] %.2lfs\n", NUM2DBL(seconds));
    }

    /*
     * Block SIG_ALRM for safe processing of SIG_ALRM configuration and save mask.
     */
    if (0 != sigprocmask(SIG_BLOCK, &sigalarm_mask, &previous_sigalarm_mask)) {
        log_error("[install_next_timer] Could not block SIG_ALRM\n", DISPLAY_ERRNO);
        return Qnil;
    }
    clear_pending_sigalrm_for_ruby_threads();
    log_debug("[install_next_timer] Successfully blocked SIG_ALRM at O.S. level\n");
	
    /*
     * Set new real time interval timer.
     */	
    set_itimerval_with_minimum_1s_interval(&timer_interval, seconds);
    if (0 != setitimer(ITIMER_REAL, &timer_interval, NULL)) {
        log_error("[install_next_timer] Could not install our own timer, timeout will not work", DISPLAY_ERRNO);
        restore_sigalrm_mask(&previous_sigalarm_mask);
        return Qnil;
    }
    if (debug_enabled) {
      log_debug("[install_next_timer] Successfully installed timer (%ds + %dus)\n", 
                timer_interval.it_value.tv_sec, timer_interval.it_value.tv_usec);
    }

    /*
     * Unblock SIG_ALRM
     */
    if (0 != sigprocmask(SIG_UNBLOCK, &sigalarm_mask, NULL)) {
        log_error("[install_next_timer] Could not unblock SIG_ALRM, timeout will not work", DISPLAY_ERRNO);
        restore_sigalrm_mask(&previous_sigalarm_mask);
    }
    log_debug("[install_next_timer] Successfully unblocked SIG_ALRM.\n");

    return Qnil;
}

static VALUE restore_original_configuration(VALUE self)
{
   /*
    * Block SIG_ALRM for safe processing of SIG_ALRM configuration.
    */
    if (0 != sigprocmask(SIG_BLOCK, &sigalarm_mask, NULL)) {
        log_error("restore_original_configuration: Could not block SIG_ALRM", errno);
    }
    clear_pending_sigalrm_for_ruby_threads();
    log_debug("[restore_original_configuration] Blocked SIG_ALRM\n");

   /*
    * Install Ruby Level SIG_ALRM handler
    */
    restore_original_ruby_sigalrm_handler(self);
	
    if (original_signal_handler.sa_handler == NULL) {
        log_error("[restore_original_configuration] Previous SIG_ALRM handler not initialized!", DO_NOT_DISPLAY_ERRNO);
    } else if (0 == sigaction(SIGALRM, &original_signal_handler, NULL)) {
        log_debug("[restore_original_configuration] Successfully restored previous handler for SIG_ALRM\n");
    } else {
        log_error("[restore_original_configuration] Could not restore previous handler for SIG_ALRM", DISPLAY_ERRNO);
    }
    original_signal_handler.sa_handler = NULL;
	
    restore_original_timer_interval();
    restore_original_sigalrm_mask_when_blocked();	
}

/*
 * Restore original timer the way it was originally set. **WARNING** Breaks original timer semantics
 *
 *   Not bothering to calculate how much time is left or if the timer already expired
 *   based on when the original timer was set and how much time is passed, just resetting 
 *   the original timer as is for the sake of simplicity.
 *
 */
static void restore_original_timer_interval() {
    if (0 != setitimer(ITIMER_REAL, &original_timer_interval, NULL)) {
        log_error("[restore_original_configuration] Could not restore original timer", DISPLAY_ERRNO);
    }
    log_debug("[restore_original_configuration] Successfully restored original timer\n");
}

static void restore_sigalrm_mask(sigset_t *previous_mask) 
{
    if (!sigismember(previous_mask, SIGALRM)) {
        sigprocmask(SIG_UNBLOCK, &sigalarm_mask, NULL);
        log_debug("[restore_sigalrm_mask] Unblocked SIG_ALRM\n");
    } else {
        log_debug("[restore_sigalrm_mask] No Need to unblock SIG_ALRM\n");
    }	
}

static void restore_original_sigalrm_mask_when_blocked() 
{
  restore_sigalrm_mask(&original_mask);
}

static void install_ruby_sigalrm_handler(VALUE self) {
    rb_thread_critical = 1;
    rb_funcall(self, rb_intern("install_ruby_sigalrm_handler"), 0);
    rb_thread_critical = 0;
}

static void restore_original_ruby_sigalrm_handler(VALUE self) {
    rb_thread_critical = 1;
    rb_funcall(self, rb_intern("restore_original_ruby_sigalrm_handler"), 0);
    rb_thread_critical = 0;
}


static VALUE debug_enabled_p(VALUE self) {
    return debug_enabled ? Qtrue : Qfalse;
}

static VALUE enable_debug(VALUE self) {
    debug_enabled = 1;
    return Qnil;
}

static VALUE disable_debug(VALUE self) {
    debug_enabled = 0;
    return Qnil;	
}

static void log_debug(char* message, ...) 
{
    va_list argp;
    
	  if (0 != debug_enabled) {
	      va_start(argp, message);
        vfprintf(stdout, message, argp);
        va_end(argp);
    }
	  return;
}

static void log_error(char* message, int display_errno)
{
    fprintf(stderr, "%s: %s\n", message, display_errno ? strerror(errno) : "");
    return;
}

/*
 * The intent is to clear SIG_ALRM signals at the Ruby level (green threads),
 * eventually triggering existing SIG_ALRM handler as a courtesy.
 * 
 * As we cannot access trap_pending_list outside of signal.c our best fallback option
 * is to trigger all pending signals at the Ruby level (potentially triggering
 * green thread scheduling).
 */
static void clear_pending_sigalrm_for_ruby_threads()
{
    CHECK_INTS;
    log_debug("[native] Successfully triggered all pending signals at Green Thread level\n");
}

static void init_sigalarm_mask() 
{
    sigemptyset(&sigalarm_mask);
    sigaddset(&sigalarm_mask, SIGALRM);
    return;
}

static void set_itimerval_with_minimum_1s_interval(struct itimerval *value, 
                                                   VALUE seconds) {

    double sanitized_second_interval;
                                                     
    sanitized_second_interval = NUM2DBL(seconds) + MINIMUM_TIMER_INTERVAL_IN_SECONDS;
    if (sanitized_second_interval < MINIMUM_TIMER_INTERVAL_IN_SECONDS ) {
        sanitized_second_interval = MINIMUM_TIMER_INTERVAL_IN_SECONDS;
    }
    set_itimerval(value, sanitized_second_interval);
}

static void set_itimerval(struct itimerval *value, double seconds) {
    if (debug_enabled) {
      log_debug("[set_itimerval] %.3lfs\n", seconds);
    }
    value->it_interval.tv_usec = 0;
    value->it_interval.tv_sec = 0;
    value->it_value.tv_sec = (long int) (seconds);
    value->it_value.tv_usec = (long int) ((seconds - value->it_value.tv_sec) \
                                          * MICRO_SECONDS);
    if (debug_enabled) {
      log_debug("[set_itimerval] Set to %ds + %dus\n", value->it_value.tv_sec, 
                                                       value->it_value.tv_usec);
    }
    return;
}


void Init_system_timer_native() 
{
    init_sigalarm_mask();
    rb_cSystemTimer = rb_define_module("SystemTimer");
    rb_define_singleton_method(rb_cSystemTimer, "install_first_timer_and_save_original_configuration", 	install_first_timer_and_save_original_configuration, 1);
    rb_define_singleton_method(rb_cSystemTimer, "install_next_timer", 	install_next_timer, 1);
    rb_define_singleton_method(rb_cSystemTimer, "restore_original_configuration", restore_original_configuration, 0);
    rb_define_singleton_method(rb_cSystemTimer, "debug_enabled?", debug_enabled_p, 0);
    rb_define_singleton_method(rb_cSystemTimer, "enable_debug", 	enable_debug, 0);
    rb_define_singleton_method(rb_cSystemTimer, "disable_debug",	disable_debug, 0);
}

#else

// Exists just to make things happy
void Init_system_timer_native()
{
  rb_cSystemTimer = rb_define_module("SystemTimer");
}

#endif
