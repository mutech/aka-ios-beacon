# AKABinding

A binding establishes a connection between a data source and a target property, such that whenever the data source changes its value, the value of the target property is updated.

Two way bindings observe both the data source and the bound target property and propagate changes in both directions.

It is important to note that two-way bindings have to distinguish between changes of the target property that have been made by the binding (which have to be ignored by two way bindings) and independent changes which have to be propagated back to the data source. 

