GNATdoc.Documentation = {
  "label": "FOC",
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
          "label": "Calculate_Voltage",
          "qualifier": "",
          "line": 25,
          "column": 13,
          "src": "srcs/foc.ads.html",
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
                      "text": "function"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Calculate_Voltage",
                      "href": "docs/foc___spec.html#L25C13"
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
                      "text": "      "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "("
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Iabc",
                      "href": "docs/foc___spec.html#L26C8"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "          "
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
                      "cssClass": "identifier",
                      "text": "Abc",
                      "href": "docs/amc_types___spec.html#L91C9"
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
                      "text": "       "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "I_Set_Point",
                      "href": "docs/foc___spec.html#L27C8"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "   "
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
                      "cssClass": "identifier",
                      "text": "Dq",
                      "href": "docs/amc_types___spec.html#L98C9"
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
                  "number": 28,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "       "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Current_Angle",
                      "href": "docs/foc___spec.html#L28C8"
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
                      "cssClass": "identifier",
                      "text": "Angle_Erad",
                      "href": "docs/amc_types___spec.html#L44C12"
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
                  "number": 29,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "       "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Vmax",
                      "href": "docs/foc___spec.html#L29C8"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "          "
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
                      "cssClass": "identifier",
                      "text": "Voltage_V",
                      "href": "docs/amc_types___spec.html#L28C12"
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
                  "number": 30,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "       "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Period",
                      "href": "docs/foc___spec.html#L30C8"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "        "
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
                      "cssClass": "identifier",
                      "text": "Seconds",
                      "href": "docs/amc_types___spec.html#L23C12"
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": ")"
                    }
                  ]
                },
                {
                  "kind": "line",
                  "number": 31,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "       "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "return"
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
                      "href": "docs/amc_types___spec.html#L91C9"
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
                  "text": "Calculates the requested inverter phase voltages as per the FOC algorithm.\n"
                }
              ]
            }
          ],
          "parameters": [
            {
              "label": "Iabc",
              "line": 26,
              "column": 8,
              "type": {
                "label": "AMC_Types.Abc",
                "docHref": "docs/amc_types___spec.html#L91C9"
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
              "label": "I_Set_Point",
              "line": 27,
              "column": 8,
              "type": {
                "label": "AMC_Types.Dq",
                "docHref": "docs/amc_types___spec.html#L98C9"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "Current set-point given in a rotor fixed reference frame\n"
                    }
                  ]
                }
              ]
            },
            {
              "label": "Current_Angle",
              "line": 28,
              "column": 8,
              "type": {
                "label": "AMC_Types.Angle_Erad",
                "docHref": "docs/amc_types___spec.html#L44C12"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "Stator-to-rotor fixed angle given in electrical radians\n"
                    }
                  ]
                }
              ]
            },
            {
              "label": "Vmax",
              "line": 29,
              "column": 8,
              "type": {
                "label": "AMC_Types.Voltage_V",
                "docHref": "docs/amc_types___spec.html#L28C12"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "Maximum allowed phase to neutral voltage\n"
                    }
                  ]
                }
              ]
            },
            {
              "label": "Period",
              "line": 30,
              "column": 8,
              "type": {
                "label": "AMC_Types.Seconds",
                "docHref": "docs/amc_types___spec.html#L23C12"
              },
              "description": [
                {
                  "kind": "paragraph",
                  "children": [
                    {
                      "kind": "span",
                      "text": "Time since last execution\n"
                    }
                  ]
                }
              ]
            }
          ],
          "returns": {
            "description": [
              {
                "kind": "paragraph",
                "children": [
                  {
                    "kind": "span",
                    "text": "A three phase voltage given in a stator fixed reference frame\n"
                  }
                ]
              }
            ]
          }
        }
      ],
      "label": "Subprograms"
    }
  ]
};