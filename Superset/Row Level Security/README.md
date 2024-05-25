## Implementing row level security

Before we dig deep into RLS lets understand our data first. We currently have sales data in our data warehouse. 

For this tutorial we will be creating rls for 3 categories 
1. Us based users (To display only us data)
2. India based users (To display only Indian data)
3. All users except Admin, Indian and US (these users will only see UNITED KINGDOM data)

These categories will help us to understand how Regular and Base filters.

Let's understand what is "Regular Filter" and what is "Base Filter"

#### 1. Regular Filter
It is very simple filter in which filter clause is applied to the table for the users added in this RLS filter. It means if you add any user in this group whatever conditions are applied will be added to the where clause of the table. 

#### 2. Base Filter
This is kind of a inverse filter. That means where clause will be applied to all the users except to those users who care added to this filter.


#### What is "Group Key"?
If user is part of multiple RLS groups then if Group Key of these groups will come into consideration. If group key is same then filters will be OR in where clause and if the key is different then AND operation will be applied on filters.