import React from 'react'

let registeredComponents = new Map();
let ready = false;

document.addEventListener('DOMContentLoaded', () => {
  ready = true;
    for (let [name, Component] of registeredComponents.entries()) {
      mountComponent(name, Component);
    }
});

function mountComponent(name, Component) {
  Array.from(document.querySelectorAll(`[data-react-component="${name}"]`))
    .map((node) => {
      let props = null;
      if (node.getAttribute('data-react-props')) {
        props = JSON.parse(node.getAttribute('data-react-props'));
      }

      React.render(<Component {...props} />, node);
    });
}

export default function registerComponent(name, Component) {
  if (registeredComponents.has(name)) {
    throw new Error(`automountComponent "${name}" already registered`);
  }

  registeredComponents.set(name, Component);

  if (ready) mountComponent(name, Component);
}
