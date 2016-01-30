/* global $, Bloodhound */
$(document).on('ready page:load', () => {
    let input;
    if (window.location.pathname.match('^/labels/')) {
        input = $('input[name="label[tags]"]');
        input.tagsinput();
    }
    if (window.location.pathname.match('^/faces/')) {
        input = $('input.typeahead');
        const commaTokenizer = ((tokenizer) => {
            return (keys) => {
                return (obj) => {
                    let tokens = [];
                    keys.forEach((key) => {
                        tokens = tokens.concat(tokenizer(obj[key]));
                    });
                    return tokens;
                };
            };
        })(str => (str || '').split(/,/));
        const source = new Bloodhound({
            prefetch: {
                url: '/labels.json',
                cache: false
            },
            identify: obj => obj.id,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: commaTokenizer(['name', 'tags'])
        });
        input.typeahead({
            minLength: 1,
            highlight: true
        }, {
            source: source,
            display: (obj) => obj.name
        });
        input.on('typeahead:select', (_, suggestion) => {
            $('input[name="face[label_id]"]').val(suggestion.id);
        });
        input.focus();
    }
});
