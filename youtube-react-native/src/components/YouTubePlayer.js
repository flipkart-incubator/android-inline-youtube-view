import React from 'react';
import PropTypes from 'prop-types';
import {
    View,
    ViewPropTypes,
    StyleSheet,
    Platform,
    requireNativeComponent,
    BackAndroid,
    BackHandler as BackHandlerModule,
} from 'react-native';

const BackHandler = BackHandlerModule || BackAndroid;

const RCTYouTube = Platform.select({
    ios: () => requireNativeComponent('ReactYouTubeView'),
    android: () => requireNativeComponent('ReactYouTubeView', YouTube, {
        nativeOnly: {
            onYouTubeError: true,
            onYouTubeErrorReady: true,
            onYouTubeErrorChangeState: true,
            onYouTubeErrorChangeQuality: true,
            onYouTubeChangeFullscreen: true,
        },
    }),
})();

export default class YouTube extends React.Component {
    static propTypes = {
        src: PropTypes.object.isRequired,
        onError: PropTypes.func,
        onReady: PropTypes.func,
        onChangeState: PropTypes.func,
        style: (ViewPropTypes && ViewPropTypes.style) || View.propTypes.style,
    };

    constructor(props) {
        super(props);
        if (props.playsInline !== undefined) {
            throw new Error(
                'YouTube.android.js: `playsInline` prop was dropped. Please use `fullscreen`',
            );
        }

        this.state = {
            moduleMargin: StyleSheet.hairlineWidth * 2,
            fullscreen: props.fullscreen,
        };
    }

    componentWillMount() {
        BackHandler.addEventListener('hardwareBackPress', this._backPress);
    }

    componentWillUnmount() {
        BackHandler.removeEventListener('hardwareBackPress', this._backPress);
    }

    _backPress = () => {
        return false;
    };

    _onError = event => {
        if (this.props.onError) {
            this.props.onError(event.nativeEvent);
        }
    };

    _onReady = event => {
        // The Android YouTube native module is pretty problematic when it comes to
        // mounting correctly and rendering inside React-Native's views hierarchy.
        // For now we must trigger some layout change to force a real render on it,
        // right after the onReady event, so it will smoothly appear after ready.
        // We also use the minimal margin to avoid `UNAUTHORIZED_OVERLAY` error from
        // the native module that is very sensitive to being covered or even touching
        // its containing view.
        this.setState({moduleMargin: event.nativeEvent.youtubeMargin});
        if (this.props.onReady) {
            this.props.onReady(event.nativeEvent);
        }
    };

    _onChangeState = event => {
        if (this.props.onChangeState) {
            this.props.onChangeState(event.nativeEvent);
        }
    };

    _onChangeQuality = event => {
        if (this.props.onChangeQuality) {
            this.props.onChangeQuality(event.nativeEvent);
        }
    };

    render() {
        return (
            <View style={[styles.container, this.props.style]}>
                <RCTYouTube
                    {...this.props}
                    style={[styles.module, {margin: this.state.moduleMargin}]}
                    onYouTubeError={this._onError}
                    onYouTubeReady={this._onReady}
                    onYouTubeChangeState={this._onChangeState}
                />
            </View>
        );
    }
}

const styles = StyleSheet.create({
    container: {
        backgroundColor: 'black',
    },
    module: {
        flex: 1,
    },
});