/**
Uses the Emojify library from https://github.com/hassankhan/emojify.js
**/
emojify.setConfig({
    emojify_tag_type : 'div',           
    img_dir          : '/assets/emoji',  
    ignored_tags     : {                
        'SCRIPT'  : 1,
        'TEXTAREA': 1,
        'A'       : 1,
        'PRE'     : 1,
        'CODE'    : 1
    }
});