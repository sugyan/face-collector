/* global $, React, Bloodhound */
/* eslint-disable no-unused-vars */
class TypeaheadLabel extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: this.props.label ? this.props.label.name : ''
        };
    }
    componentDidMount() {
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
                url: '/labels/all.json'
            },
            identify: obj => obj.id,
            queryTokenizer: Bloodhound.tokenizers.whitespace,
            datumTokenizer: commaTokenizer(['name', 'tags', 'twitter'])
        });
        $(this.refs.input).typeahead({
            minLength: 1,
            highlight: true
        }, {
            source: source,
            display: (obj) => {
                let ret = `${obj.name} - ${obj.description || ''}`;
                if (obj.twitter) {
                    ret += ` (@${obj.twitter})`;
                }
                return ret;
            },
            limit: 10
        }).on('typeahead:select', (_, suggestion) => {
            $('#name').html(
                $('<a>')
           .attr('href', suggestion.url)
           .text(suggestion.name)
            );
            $(this.refs.hidden).val(suggestion.id);
        }).focus();
    }
    handleChange(event) {
        this.setState({
            value: event.target.value
        });
    }
    render() {
        return (
            <div>
              <input
                  ref="input"
                  value={this.state.value}
                  onChange={this.handleChange.bind(this)}
                  className="typeahead form-control" />
              <input
                  ref="hidden"
                  name={this.props.name}
                  type="hidden" />
              <button className="btn btn-primary" style={{ marginLeft: 10 }}>Update</button>
            </div>
        );
    }
}
