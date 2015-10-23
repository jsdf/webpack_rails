import React from 'react'

const registeredComponents = new Map();
const mountedComponentNodes = new Map();
let ready = false;

function mountComponent(Component, name) {
  Array.from(document.querySelectorAll(`[data-react-component="${name}"]`))
    .map((node) => {
      let props = null;
      if (node.getAttribute('data-react-props')) {
        props = JSON.parse(node.getAttribute('data-react-props'));
      }

      React.render(<Component {...props} />, node);
      mountedComponentNodes.set(name, node);
    });
}

function unmountComponent(name) {
  if (mountedComponentNodes.has(name)) {
    React.unmountComponentAtNode(mountedComponentNodes.get(name));
    mountedComponentNodes.delete(name);
  }
}

function unregisterComponent(name) {
  if (registeredComponents.has(name)) {
    registeredComponents.delete(name);
  }
  unmountComponent(name);
}

export default function registerComponent(name, Component) {
  if (registeredComponents.has(name)) {
    throw new Error(`registerComponent "${name}" already registered`);
  }
  registeredComponents.set(name, Component);

  if (ready) mountComponent(Component, name);

  return () => unregisterComponent(name);
}


document.addEventListener('DOMContentLoaded', () => {
  ready = true;
  registeredComponents.forEach(mountComponent);
});
