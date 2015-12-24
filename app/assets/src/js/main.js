/* global $, Bloodhound */
$(document).on('ready page:load', () => {
    if (window.location.pathname.match('^/labels/')) {
        let input = $('input[name="label[tags]"]');
        input.tagsinput();
    }
    if (window.location.pathname.match('^/faces/')) {
        let input = $('input.typeahead');
        let commaTokenizer = ((tokenizer) => {
            return (keys) => {
                return (obj) => {
                    let tokens = [];
                    keys.forEach((key) => {
                        tokens = tokens.concat(tokenizer(obj[key]));
                    });
                    return tokens;
                };
            };
        })(str => str.split(/,/));
        let source = new Bloodhound({
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
