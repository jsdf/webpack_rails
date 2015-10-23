import PostsScreen from './PostsScreen'
import registerComponent from '../automountComponent'

const unregisterComponent = registerComponent('PostsScreen', PostsScreen);

// not needed with react-transform-hmr
if (module.hot) {
  module.hot.accept();
  module.hot.dispose(unregisterComponent);
}
