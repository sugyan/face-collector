/* global $, Bloodhound */
$(document).on('ready page:load', () => {
    if (window.location.pathname.match('^/labels/')) {
        let input = $('input[name="label[tags]"]');
        input.tagsinput();
    }
    if (window.location.pathname.match('^/faces/')) {
        let input = $('input[name="face[label_id]"]');
        let source = new Bloodhound({
            initialize: false,
            local: ['dog', 'pig', 'moose'],
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: Bloodhound.tokenizers.whitespace
        });
        source.initialize();
        input.typeahead({
            minLength: 1,
            highlight: true
        }, {
            source: source
        });
        input.focus();
    }
});
