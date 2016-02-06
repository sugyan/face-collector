/* global $, Bloodhound */
$(document).on('ready page:load', () => {
    let input;
    if (window.location.pathname.match('^/collector/labels/')) {
        input = $('input[name="label[tags]"]');
        input.tagsinput();
    }
    if (window.location.pathname.match('^/collector/faces/')) {
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
                url: '/collector/labels/all.json',
                cache: false
            },
            identify: obj => obj.id,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: commaTokenizer(['name', 'tags', 'twitter'])
        });
        input.typeahead({
            minLength: 1,
            highlight: true
        }, {
            source: source,
            display: (obj) => {
                let ret = `${obj.name} - ${obj.description}`;
                if (obj.twitter) {
                    ret += ` (@${obj.twitter})`;
                }
                return ret;
            }
        });
        input.on('typeahead:select', (_, suggestion) => {
            $('#name').html(
                $('<a>')
                    .attr('href', suggestion.url)
                    .text(suggestion.name)
            );
            $('input[name="face[label_id]"]').val(suggestion.id);
        });
        input.focus();
    }
});
