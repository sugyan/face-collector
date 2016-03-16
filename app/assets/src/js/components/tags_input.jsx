/* global $, React */
/* eslint-disable no-unused-vars */
class TagsInput extends React.Component {
    constructor(props) {
        super(props);
        this.state = {
            value: this.props.value
        };
    }
    componentDidMount() {
        $(this.refs.input).tagsinput();
    }
    handleChange() {
    }
    render() {
        return (
            <input
                ref="input"
                name={this.props.name}
                value={this.state.value}
                onChange={this.handleChange.bind}
                className="form-control">
            </input>
        );
    }
}
