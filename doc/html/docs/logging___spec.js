GNATdoc.Documentation = {
  "label": "Logging",
  "qualifier": "",
  "summary": [
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "Logging\n"
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
          "text": "This package contain features for logging data. It includes a task responsible\n"
        },
        {
          "kind": "span",
          "text": "for collecting data of interest and to send it to a specified IO.\n"
        },
        {
          "kind": "span",
          "text": "It calls the Calmeas package that will buffer the values of logged variables.\n"
        },
        {
          "kind": "span",
          "text": "The task then calls the communication stack as to send the logged data and to\n"
        },
        {
          "kind": "span",
          "text": "check for received data (e.g. requests to change value of a variable,\n"
        },
        {
          "kind": "span",
          "text": "or set the Calmeas sample rate).\n"
        },
        {
          "kind": "span",
          "text": "Here you could also add logging to other media, for example Bluetooth, CAN or SD.\n"
        }
      ]
    }
  ],
  "entities": [
    {
      "entities": [
        {
          "label": "Logger",
          "qualifier": "",
          "line": 17,
          "column": 9,
          "src": "srcs/logging.ads.html",
          "summary": [
          ],
          "href": "../docs/logging___logger___spec.html#L17C9"
        }
      ],
      "label": "Tasks and task types"
    }
  ]
};