GNATdoc.Documentation = {
  "label": "Current_Control.FOC",
  "qualifier": "",
  "summary": [
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "Field Oriented Control\n"
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
          "text": "Implements a controller using state vector representation.\n"
        }
      ]
    },
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "The algorithm is divided into three parts:\n"
        }
      ]
    },
    {
      "kind": "ul",
      "children": [
        {
          "kind": "li",
          "children": [
            {
              "kind": "span",
              "text": "Transform the values into a rotor fixed reference frame.\n"
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "Uses Clarke Park transformation assuming a given stator-to-rotor angle\n"
                }
              ]
            }
          ]
        },
        {
          "kind": "li",
          "children": [
            {
              "kind": "span",
              "text": "Based on the requested current, calculate a new set of phase voltages\n"
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "Uses two PID controllers, one controlling the field flux linkage component\n"
                },
                {
                  "kind": "span",
                  "text": "(Id) and one controlling the torque component (Iq).\n"
                }
              ]
            }
          ]
        },
        {
          "kind": "li",
          "children": [
            {
              "kind": "span",
              "text": "Transform back to the stator's reference frame\n"
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "Uses Park Clarke transformation assuming a given stator-to-rotor angle\n"
                }
              ]
            }
          ]
        }
      ]
    },
    {
      "kind": "paragraph",
      "children": [
        {
          "kind": "span",
          "text": "For more information, see https://en.wikipedia.org/wiki/Vector_control_(motor)\n"
        }
      ]
    }
  ],
  "entities": [
    {
      "entities": [
        {
          "label": "Update",
          "qualifier": "",
          "line": 25,
          "column": 14,
          "src": "srcs/current_control-foc.ads.html",
          "summary": [
          ],
          "description": [
            {
              "kind": "code",
              "children": [
                {
                  "kind": "line",
                  "number": 25,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "   "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "procedure"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Update",
                      "href": "docs/current_control__foc___spec.html#L25C14"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "("
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Phase_Currents",
                      "href": "docs/current_control__foc___spec.html#L25C22"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "in"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Abc",
                      "href": "docs/amc_types___spec.html#L136C9"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 26,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "                     "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "System_Outputs",
                      "href": "docs/current_control__foc___spec.html#L26C22"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "in"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "AMC.Inverter_System_States",
                      "href": "docs/amc___spec.html#L36C9"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 27,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "                     "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Duty",
                      "href": "docs/current_control__foc___spec.html#L27C22"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "           "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ":"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "out"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Abc",
                      "href": "docs/amc_types___spec.html#L136C9"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ")"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ";"
                    }
                  ]
                }
              ]
            },
            {
              "kind": "paragraph",
              "children": [
                {
                  "kind": "span",
                  "text": "Calculates the requested inverter phase duty as per the FOC algorithm.\n"
                }
              ]
            }
          ],
          "parameters": [
            {
              "label": "Phase_Currents",
              "line": 25,
              "column": 22,
              "type": {
                "label": "AMC_Types.Abc",
                "docHref": "docs/amc_types___spec.html#L136C9"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "A three phase current\n"
                    }
                  ]
                }
              ]
            },
            {
              "label": "System_Outputs",
              "line": 26,
              "column": 22,
              "type": {
                "label": "AMC.Inverter_System_States",
                "docHref": "docs/amc___spec.html#L36C9"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "Includes system variables such as the current set-point\n"
                    },
                    {
                      "kind": "span",
                      "text": "and the bus voltage etc.\n"
                    }
                  ]
                }
              ]
            },
            {
              "label": "Duty",
              "line": 27,
              "column": 22,
              "type": {
                "label": "AMC_Types.Abc",
                "docHref": "docs/amc_types___spec.html#L136C9"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "A triplet of values representing the calculated duty cycles\n"
                    }
                  ]
                }
              ]
            }
          ]
        }
      ],
      "label": "Subprograms"
    }
  ]
};