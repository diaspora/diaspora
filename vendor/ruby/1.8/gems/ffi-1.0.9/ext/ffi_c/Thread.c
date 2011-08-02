/*
 * Copyright (c) 2010 Wayne Meissner
 *
 * All rights reserved.
 *
 * This file is part of ruby-ffi.
 *
 * This code is free software: you can redistribute it and/or modify it under
 * the terms of the GNU Lesser General Public License version 3 only, as
 * published by the Free Software Foundation.
 *
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General Public License
 * version 3 for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * version 3 along with this work.  If not, see <http://www.gnu.org/licenses/>.
 */

#include <stdbool.h>

#ifndef _WIN32
# include <pthread.h>
# include <errno.h>
# include <signal.h>
#else
# include <windows.h>
#endif
#include <fcntl.h>
#include "Thread.h"


#ifndef HAVE_RUBY_THREAD_HAS_GVL_P
rbffi_thread_t rbffi_active_thread;

rbffi_thread_t
rbffi_thread_self()
{
    rbffi_thread_t self;
#ifdef _WIN32
    self.id = GetCurrentThreadId();
#else
    self.id = pthread_self();
#endif
    self.valid = true;

    return self;
}

bool
rbffi_thread_equal(const rbffi_thread_t* lhs, const rbffi_thread_t* rhs)
{
    return lhs->valid && rhs->valid && 
#ifdef _WIN32
            lhs->id == rhs->id;
#else
            pthread_equal(lhs->id, rhs->id);
#endif
}

bool
rbffi_thread_has_gvl_p(void)
{
#ifdef _WIN32
    return rbffi_active_thread.valid && rbffi_active_thread.id == GetCurrentThreadId();
#else
    return rbffi_active_thread.valid && pthread_equal(rbffi_active_thread.id, pthread_self());
#endif
}
#endif // HAVE_RUBY_THREAD_HAS_GVL_P

#ifndef HAVE_RB_THREAD_BLOCKING_REGION

#if !defined(_WIN32)

struct BlockingThread {
    pthread_t tid;
    VALUE (*fn)(void *);
    void *data;
    void (*ubf)(void *);
    void *data2;
    VALUE retval;
    int wrfd;
    int rdfd;
};

static void*
rbffi_blocking_thread(void* args)
{
    struct BlockingThread* thr = (struct BlockingThread *) args;
    char c = 1;
    VALUE retval;
    
    retval = (*thr->fn)(thr->data);
    
    pthread_testcancel();

    thr->retval = retval;
    
    write(thr->wrfd, &c, sizeof(c));

    return NULL;
}

static VALUE
wait_for_thread(void *data)
{
    struct BlockingThread* thr = (struct BlockingThread *) data;
    char c;
    
    if (read(thr->rdfd, &c, 1) < 1) {
        rb_thread_wait_fd(thr->rdfd);
        while (read(thr->rdfd, &c, 1) < 1 && rb_io_wait_readable(thr->rdfd) == Qtrue) {
            ;
        }
    }

    return Qnil;
}

static VALUE
cleanup_blocking_thread(void *data, VALUE exc)
{
    struct BlockingThread* thr = (struct BlockingThread *) data;

    if (thr->ubf != (void (*)(void *)) -1) {
        (*thr->ubf)(thr->data2);
    } else {
        pthread_kill(thr->tid, SIGVTALRM);
    }

    return exc;
}

VALUE
rbffi_thread_blocking_region(VALUE (*func)(void *), void *data1, void (*ubf)(void *), void *data2)
{
    struct BlockingThread* thr;
    int fd[2];
    VALUE exc;
    
    if (pipe(fd) < 0) {
        rb_raise(rb_eSystemCallError, "pipe(2) failed");
        return Qnil;
    }
    fcntl(fd[0], F_SETFL, fcntl(fd[0], F_GETFL) | O_NONBLOCK);

    thr = ALLOC_N(struct BlockingThread, 1);
    thr->rdfd = fd[0];
    thr->wrfd = fd[1];
    thr->fn = func;
    thr->data = data1;
    thr->ubf = ubf;
    thr->data2 = data2;
    thr->retval = Qnil;

    if (pthread_create(&thr->tid, NULL, rbffi_blocking_thread, thr) != 0) {
        close(fd[0]);
        close(fd[1]);
        xfree(thr);
        rb_raise(rb_eSystemCallError, "pipe(2) failed");
        return Qnil;
    }

    exc = rb_rescue2(wait_for_thread, (VALUE) thr, cleanup_blocking_thread, (VALUE) thr,
        rb_eException);
    
    pthread_join(thr->tid, NULL);
    close(fd[1]);
    close(fd[0]);
    xfree(thr);

    if (exc != Qnil) {
        rb_exc_raise(exc);
    }

    return thr->retval;
}

#else

/*
 * FIXME: someone needs to implement something similar to the posix pipe based
 * blocking region implementation above for ruby1.8.x on win32
 */
VALUE
rbffi_thread_blocking_region(VALUE (*func)(void *), void *data1, void (*ubf)(void *), void *data2)
{
    return (*func)(data1);
}

#endif /* !_WIN32 */

#endif // HAVE_RB_THREAD_BLOCKING_REGION

