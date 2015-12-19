/* global $ */
$(document).on('ready page:change', () => {
    if (window.location.pathname.match('^/labels/[0-9]+/')) {
        const label_tag  = $('input[name="label[tags]"]');
        label_tag.tagsinput();
    }
});
