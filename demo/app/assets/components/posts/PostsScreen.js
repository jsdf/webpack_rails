import React from 'react'

export default class PostsScreen extends React.Component {
  render() {
    return (
      <div>
        <h1>Posts</h1>
        {this.props.posts.map((post, i) => <div key={i}>{post.title}</div>)}
      </div>
    );
  }
}

