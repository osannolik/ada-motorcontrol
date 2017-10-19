GNATdoc.Documentation = {
  "label": "AMC_Hall.Commutation",
  "qualifier": "",
  "summary": [
  ],
  "description": [
  ],
  "entities": [
    {
      "entities": [
        {
          "label": "Await_Commutation",
          "qualifier": "",
          "line": 133,
          "column": 13,
          "src": "srcs/amc_hall.ads.html",
          "summary": [
          ],
          "description": [
            {
              "kind": "code",
              "children": [
                {
                  "kind": "line",
                  "number": 133,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "      "
                    },
                    {
                      "kind": "span",
                      "cssClass": "keyword",
                      "text": "entry"
                    },
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": " "
                    },
                    {
                      "kind": "span",
                      "cssClass": "identifier",
                      "text": "Await_Commutation",
                      "href": "docs/amc_hall___commutation___spec.html#L133C13"
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
                  "text": "Suspend the caller and wake it up again as soon as commutation shall occur.\n"
                },
                {
                  "kind": "span",
                  "text": "Nominally, the time for this commutation is the time since last hall state change plus\n"
                },
                {
                  "kind": "span",
                  "text": "Time_Delta_s * Commutation_Delay_Factor,\n"
                },
                {
                  "kind": "span",
                  "text": "i.e. if factor is 0.5 then commutation is halfway between two hall state changes\n"
                },
                {
                  "kind": "span",
                  "text": "(assuming constant speed).\n"
                }
              ]
            }
          ]
        }
      ],
      "label": "Entries"
    },
    {
      "entities": [
        {
          "label": "Manual_Trigger",
          "qualifier": "",
          "line": 140,
          "column": 17,
          "src": "srcs/amc_hall.ads.html",
          "summary": [
          ],
          "description": [
            {
              "kind": "code",
              "children": [
                {
                  "kind": "line",
                  "number": 140,
                  "children": [
                    {
                      "kind": "span",
                      "cssClass": "text",
                      "text": "      "
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
                      "text": "Manual_Trigger",
                      "href": "docs/amc_hall___commutation___spec.html#L140C17"
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
                  "text": "Manually trigger a commutation event.\n"
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