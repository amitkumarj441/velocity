# velocity
Track development velocity

Files in `BigQuery/*.sql` are Google BigQuery SQLs that generated data in `data/` directory

`analysis.rb` is a tool that process input file (which is an output from BigQuery) and generates final data for Bubble/Motion Google Sheet Chart.
It uses:
- hints file with additional repo name -> project mapping. (N repos --> 1 Project), so project name will be in many lines
- urls file which defines URLs for defined projects (separate file because in hints file we would have to duplicate data for each project ) (1 Project --> 1 URL)
- default map file which defines non standard names for projects generated automatically via groupping by org (like aspnet --> ASP.net) or to group multiple orgs and/or repos into single project. It is a last step of project name mapping

# Example use:
`ruby analysis.rb data/data_yyyymm.csv projects/projects_yyyymm.csv map/hints.csv map/urls.csv map/defmaps.csv`

`input.csv` data/data_yyyymm.csv from BigQuery, like this:
```
org,repo,activity,comments,prs,commits,issues,authors
kubernetes,kubernetes/kubernetes,11243,9878,720,70,575,40
ethereum,ethereum/go-ethereum,10701,570,109,43,9979,14
...
```

`output.csv` to be imported via Google Sheet (File -> Import) and then chart created from this data. It looks like this:
```
org,repo,activity,comments,prs,commits,issues,authors,project,url
dotnet,corefx+coreclr+roslyn+cli+docs+core-setup+corefxlab+roslyn-project-system+sdk+corert+eShopOnContainers+core+buildtools,20586,14964,1956,1906,1760,418,dotnet,microsoft.com/net
kubernetes+kubernetes-incubator,kubernetes+kubernetes.github.io+test-infra+ingress+charts+service-catalog+helm+minikube+dashboard+bootkube+kargo+kube-aws+community+heapster,20249,15735,2013,1323,1178,423,Kubernetes,kubernetes.io
...
```

`hints.csv` CSV file with hints for repo --> project, it looks like this:
```
repo,project
Microsoft/TypeScript,Microsoft TypeScript
...
```

`urls.csv` CSV file with project --> url mapping
```
project,url
Angular,angular.io
...
```

`defmaps.csv` CSV file with better names for projects generated as default groupping within org:
```
name,project
aspnet,ASP.net
nixpkgs,NixOS
...
```

Generated output file contains all data from input (so it can be 600 rows for 1000 input rows for example).
You should manually review generated output and choose how much rows do You need.

`hintgen.rb` is a tool that takes data already processed for various created charts and creates distinct projects hint file from it:

`hintgen.rb data.csv map/hints.csv`
Use multiple times putting different files as 1st parameter (`data.csv`) and generate final `hints.csv`.

Already generated data:
- data/data_YYYYMM.csv --> data for given YYYYMM from BigQuery.
- projects/projects_YYYYMM.csv --> data generated by `analysis.rb` from data_YYYYMM.csv using: `map/`: `hints.csv`, `urls.csv`, `defmaps.csv`


`generate_motion.rb` tool is used to merge data from multiple files into one for motion chart. Usage:

`ruby generate_motion.rb projects/files.csv motion/motion.csv motion/motion_sums.csv`

File `files.csv` contains list of data files to be merged, it looks like this:
```
name,label
projects/projects_201601.csv,01/2016
projects/projects_201602.csv,02/2016
...
```

Generates 2 output files:
- 1st is a motion data from each file with given label
- 2nd is cumulative sum of data, so 1st label contains data from 1st label, 2nd contains 1st+2nd, 3rd=1st+2nd+3rd ... last = sum of all data. Labels are summed in alphabetical order so if using months please use "YYYYMM" or "YYYY-MM" that will give correct results, and not "MM/YYYY" that will for example swap "2/2016" and "1/2017"

Output formats of 1st and 2nd files are identical.

First column is data file generated by `analysis.rb` another column is label that will be used as "time" for google sheets motion chart
Output is in format:
```
project,url,label,activity,comments,prs,commits,issues,authors,sum_activity,sum_comments,sum_prs,sum_commits,sum_issues,sum_authors
Kubernetes,kubernetes.io,2016-01,6289,5211,548,199,331,73,174254,136104,18264,8388,11498,373
Kubernetes,kubernetes.io,2016-02,13021,10620,1180,360,861,73,174254,136104,18264,8388,11498,373
...
Kubernetes,kubernetes.io,2017-04,174254,136104,18264,8388,11498,373,174254,136104,18264,8388,11498,373
dotnet,microsoft.com/net,2016-01,8190,5933,779,760,718,158,158624,111553,17019,17221,12831,382
dotnet,microsoft.com/net,2016-02,17975,12876,1652,1908,1539,172,158624,111553,17019,17221,12831,382
...
dotnet,microsoft.com/net,2017-04,158624,111553,17019,17221,12831,382,158624,111553,17019,17221,12831,382
VS Code,code.visualstudio.com,2016-01,7526,5278,381,804,1063,112,155621,104386,9501,17650,24084,198
VS Code,code.visualstudio.com,2016-02,17139,11638,986,1899,2616,133,155621,104386,9501,17650,24084,198
...
VS Code,code.visualstudio.com,2017-04,155621,104386,9501,17650,24084,198,155621,104386,9501,17650,24084,198
...
```
Each row contains its label data (cumulative or separata) and columns with staring with `max_` conatin cumulative data for all labels.
This is to make this data easy available for google sheet motion chart without complex cell indexing.


# Results:

NOTE: for viewing using those motion charts You'll need Adobe Flash enabled when clicking links. It works (tested) on Chrome and Safari with Adobe Flash installed and enabled.

For data from files.csv (data/data_YYYYMM.csv), 201601 --> 201703 (15 months)
Chart with cumulative data (each month is sum of this month and previous months) is here:
https://docs.google.com/spreadsheets/d/11qfS97WRwFqNnArRmpQzCZG_omvZRj_y-MNo5oWeULs/edit?usp=sharing
Chart with monthly data (that looks wrong IMHO due to google motion chart data interpolation between moths) is here: 
https://docs.google.com/spreadsheets/d/1ZgdIuMxxcyt8fo7xI1rMeFNNx9wx0AxS-2a58NlHtGc/edit?usp=sharing

I suggest play around with 1st chart (cumulative sum):
It is not able to remember settings so once You click on "Chart1" scheet I suggest:
- Change axis-x and axis-y from Lin (linerar) to Log (logarithmics)
- You can choose what column should be used for color: I suggest activity (this is default and shows which project was most active) or choose unique color (You can select from commits, prs+issues, size) (size is square root of number of authors)
- Change playback speed (control next to play) to slowest
- Select inerested projects from Legend (like Kubernetes for example or Kubernetes vs dotnet etc) and check "trails"
- You can also change what x and y axisis use as data, defaults are: x=commits, y=pr+issues, and change scale type lin/log
- You can also change which column use for bubble size (default is "size" which means square root of number of authors), note that number of authors = max from all monts (distinct authors that contributed to activity), this is obviously differnt from set of distinct authors activity in entire 15 months range

On the top/right just above the Color drop down You can see additional two chart types:
- Bar chart - this can be very useful
- Choose li or log y-axis scale, then select Kubernetes from Legend and then choose any of y-axis possible values (activity, commits, PRs+issues, Size) and click play to see how Kubernetes overtakes multiple projects during our period.
Finally there is also a linear chart, take a look on it too.

# Published:
https://docs.google.com/spreadsheets/d/11qfS97WRwFqNnArRmpQzCZG_omvZRj_y-MNo5oWeULs/pubhtml

# Shared:
https://docs.google.com/spreadsheets/d/1S-YLoma7-j6koN86gCCy_WwdgQNghk1SFuHuzXcQcnc/edit?usp=sharing
https://docs.google.com/spreadsheets/d/1MuulhPL_SHia7IQYWfgo4IWvkiLq5EJILtRJ_OvxHxc/edit?usp=sharing
https://docs.google.com/spreadsheets/d/1bERALoPEavrBcyXuaArAXHg5b2m0v6CEm_RI0KBLddQ/edit?usp=sharing


# List of all charts:
Top 30 projects March 2017 (bubble): https://docs.google.com/spreadsheets/d/1WO1NCzeso7_srYPMS3nspnAeqOImPDReAaOyZSIPJE4/edit?usp=sharing
Top 30 projects April 2017 (bubble): https://docs.google.com/spreadsheets/d/1bERALoPEavrBcyXuaArAXHg5b2m0v6CEm_RI0KBLddQ/edit?usp=sharing
Top 30 projects January - March 2017 (bubble): https://docs.google.com/spreadsheets/d/1EU6MCGld5EV2TAVTStbdvis9O2Vf6Xtust1Mpu_RkWo/edit?usp=sharing
Top 30 projects January - April 2017 (bubble): https://docs.google.com/spreadsheets/d/1MuulhPL_SHia7IQYWfgo4IWvkiLq5EJILtRJ_OvxHxc/edit?usp=sharing
Top 30 projects January 2016 - April 2017 (motion): https://docs.google.com/spreadsheets/d/1S-YLoma7-j6koN86gCCy_WwdgQNghk1SFuHuzXcQcnc/edit?usp=sharing
Top 30 projects January 2016 - April 2017 (motion logaritmic): https://docs.google.com/spreadsheets/d/1y8uQ4wrMMd5Ghy8gHjrZ4N8ZpF0DY-ti8V7cQqxwUmE/edit?usp=sharing
