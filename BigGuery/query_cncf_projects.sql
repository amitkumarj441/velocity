select
  org.login as org,
  repo.name as repo,
  count(*) as activity,
  SUM(IF(type = 'IssueCommentEvent', 1, 0)) as comments,
  SUM(IF(type = 'PullRequestEvent', 1, 0)) as prs,
  SUM(IF(type = 'PushEvent', 1, 0)) as commits,
  SUM(IF(type = 'IssuesEvent', 1, 0)) as issues,
  EXACT_COUNT_DISTINCT(JSON_EXTRACT(payload, '$.commits[0].author.email')) AS authors
from 
  (select * from
    [githubarchive:month.201605],
    [githubarchive:month.201606],
    [githubarchive:month.201607],
    [githubarchive:month.201608],
    [githubarchive:month.201609],
    [githubarchive:month.201610],
    [githubarchive:month.201611],
    [githubarchive:month.201612],
    [githubarchive:month.201701],
    [githubarchive:month.201702],
    [githubarchive:month.201703],
    [githubarchive:month.201704]
  )
where
  (
    org.login in (
      'kubernetes', 'prometheus', 'opentracing', 'fluent', 'linkerd', 'grpc', 'coredns', 'containerd',
      'rkt', 'kubernetes-client', 'kubernetes-contrib', 'kubernetes-cluster-automation',
      'kubernetes-incubator', 'kubernetes-ui'
    )
    or repo.name in (
      'docker/containerd', 'coreos/rkt', 'fabric8io/docker-fluentd', 'fabric8io/docker-fluentd-kubernetes',
      'deis/fluentd', 'grpc-ecosystem/grpc-opentracing', 'coreos/kube-prometheus', 'coreos/prometheus',
      'coreos/prometheus-operator', 'coreos/coreos-kubernetes', 'coreos/kubernetes', 'abric8io/kubernetes-client',
      'abric8io/kubernetes-model', 'vmware/kubernetes'
    )
  )
  and type in ('IssueCommentEvent', 'PullRequestEvent', 'PushEvent', 'IssuesEvent')
  and actor.login not like '%bot%'
  AND actor.login NOT IN (
    SELECT
      actor.login
    FROM (
      SELECT
        actor.login,
        COUNT(*) c
      FROM
      [githubarchive:month.201603],
      [githubarchive:month.201604]
      WHERE
        type = 'IssueCommentEvent'
      GROUP BY
        1
      HAVING
        c > 2000
      ORDER BY
      2 DESC
    )
  )
group by org, repo
order by
  activity desc
limit 10000;