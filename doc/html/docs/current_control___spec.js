GNATdoc.Documentation = {
  "label": "Current_Control",
  "qualifier": "",
  "summary": [
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "Current controller\n"
        }
      ]
    }
  ],
  "description": [
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "This package is responsible for calculating and setting the switching\n"
        },
        {
          "kind": "span",
          "text": "duty cycle, typically in order to achieve the set-point stator currents.\n"
        }
      ]
    },
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "Contained is a task that is triggered when new samples of the\n"
        },
        {
          "kind": "span",
          "text": "phase currents and voltages are available. This is typically triggered by\n"
        },
        {
          "kind": "span",
          "text": "the ADC. The current controller will take the ADC readings and, depending\n"
        },
        {
          "kind": "span",
          "text": "on the specific control algorithm, control the stator current by commanding\n"
        },
        {
          "kind": "span",
          "text": "a new triplet of duty cycles to the PWM peripheral. The current set-point,\n"
        },
        {
          "kind": "span",
          "text": "control mode etc. is read from the Inverter_System task.\n"
        }
      ]
    }
  ],
  "entities": [
    {
      "entities": [
        {
          "label": "Current_Control",
          "qualifier": "",
          "line": 20,
          "column": 9,
          "src": "srcs/current_control.ads.html",
          "summary": [
          ],
          "href": "../docs/current_control___current_control___spec.html#L20C9"
        }
      ],
      "label": "Tasks and task types"
    }
  ]
};