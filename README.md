# Contributor classifier


## `directory_classifier:contributors`

Outputs directory classifications by contributors

Example:

```bash
rake directory_classifier:contributors[\
'/Users/neil.atkinson/work/api',\
'/Users/neil.atkinson/work/api/app;/Users/neil.atkinson/work/api/spec;/Users/neil.atkinson/work/api/lib/tasks;/Users/neil.atkinson/work/api/gems',\
'/Users/neil.atkinson/work/directory_classifier/example_contributors.yml',\
'/Users/neil.atkinson/work/directory_classifier/contributions_output.csv'\
]
```

## `directory_classifier:categories`

Outputs directory classifications by category

Example:

```bash
rake directory_classifier:categories[\
'/Users/neil.atkinson/work/api',\
'/Users/neil.atkinson/work/api/app;/Users/neil.atkinson/work/api/spec;/Users/neil.atkinson/work/api/lib/tasks;/Users/neil.atkinson/work/api/gems',\
'/Users/neil.atkinson/work/directory_classifier/example_categories.yml',\
'/Users/neil.atkinson/work/directory_classifier/categories_output.csv'\
]
```
