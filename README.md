# velocity
Track development velocity

`analysis.rb` is a tool that process input file (which is an aoutput from BigQuery) and generates final data for Bubble/Motion Google Sheet Chart.
It uses:
- hints file with additional repo name -> project mapping. (N repos --> 1 Project), so project name will be in many lines
- urls file which defines URLs for defined projects (separate file because in hints file we would have to duplicate data for each project ) (1 Project --> 1 URL)
- default map file which defines non standard names for projects generated automatically via groupping by org (like aspnet --> ASP.net) or to group multiple orgs and/or repos into single project. It is as last step
Example use:
`analysis.rb input.csv output.csv hints.csv urls.csv defmaps.csv`

`input.csv` data from BigQuery, like this:
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

`hint.csv` CSV file with hints for repo --> project, it looks like this:
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

`defmaps.csv` CSV file with better names for projects generated as default groupping withing org:
```
name,project
aspnet,ASP.net
nixpkgs,NixOS
...
```

Generated output file contains all data from input (so it can be 600 rows for 1000 input rows for example).
You should manually review generated output and choose how much rows do You need.

`hintgen.rb` is a tool that takes data already processed for various created charts and creates distinct projects hint file from it:
`hintgen.rb data.csv hints.csv`
Use multiple times putting different files as 1st parameter (`data.csv`) and generate final `hints.csv`.
