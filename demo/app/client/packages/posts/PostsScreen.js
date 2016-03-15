import React from 'react'

const ENV_TEST_VALUE = WEBPACK_TEST_DEFINE;

export default class PostsScreen extends React.Component {
  render() {
    return (
      <div>
        <h1>Posts</h1>
        {this.props.posts.map((post, i) => <div key={i}>{post.title}</div>)}
        {ENV_TEST_VALUE}
      </div>
    );
  }
}
