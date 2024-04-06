
## Create Custom theme pallet 
To Create custom theme pallet update following and add it to superset config (superset_config.py) file. Reboot superset once done.

```
EXTRA_CATEGORICAL_COLOR_SCHEMES = [
     {
         "id": 'world_population_reporting_colors',
         "description": '',
         "label": 'World Population Reporting colors',
         "colors":
          ['#004369', '#65D0E4', '#50BEF3', '#65D0E4', '#7D82EA', '#AA5ECB', '#CE42A1',
          '#EC487D', '#FA6E67', '#FFA064', '#EEDD55', '#9977BB', '#BBAA44', '#DDCCDD']
     }]
```
