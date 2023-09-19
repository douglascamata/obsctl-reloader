{
  prometheusAlerts+:: {
    groups+: [
      {
        name: 'obsctl-reloader.rules',
        rules: [
          {
            alert: 'ObsCtlRulesStoreInternalServerError',
            expr: |||
              (
                sum_over_time(obsctl_reloader_prom_rules_store_ops_total{status_code=~"5..|4..", %(obsctlReloaderSelector)s}[5m])
              /
                sum_over_time(obsctl_reloader_prom_rules_store_ops_total{status_code=~"2..", %(obsctlReloaderSelector)s}[5m])
              ) or vector(0)
              > 0.10
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Failing to send rules to Observatorium.',
              description: 'Failed to send rules from tenant {{ $labels.tenant }} to store {{ $value | humanizePercentage }}% of the time with a 5xx or 4xx status code.',
            },
          },
          {
            alert: 'ObsCtlRulesSetFailure',
            expr: |||
              (
                sum_over_time(obsctl_reloader_prom_rule_set_failures_total{%(obsctlReloaderSelector)s}[5m])
              /
                sum_over_time(obsctl_reloader_prom_rule_set_total{%(obsctlReloaderSelector)s}[5m])
              ) or vector(0)
              > 0.10
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Failing to set rules in the rules store.',
              description: 'obsctl-reloader is failing to set rules for tenant {{ $labels.tenant }} in the rules store {{ $value | humanizePercentage }}% of the time due to {{ $labels.reason }}.',
            },
          },
          {
            alert: 'ObsCtlRulesStoreAuthenticationError',
            expr: |||
              (
                sum_over_time(obsctl_reloader_prom_rules_store_ops_total{status_code=~"403", %(obsctlReloaderSelector)s}[5m])
              /
                sum_over_time(obsctl_reloader_prom_rules_store_ops_total{status_code=~"2..", %(obsctlReloaderSelector)s}[5m])
              ) or vector(0)
              > 0.10
            ||| % $._config,
            'for': '10m',
            labels: {
              severity: 'warning',
            },
            annotations: {
              summary: 'Failing to authenticate tenant with Observatorium.',
              description: 'Failed to authenticate tenant {{ $labels.tenant }} with Observatorium.',
            },
          },
          {
            alert: 'ObsCtlFetchRulesFailed',
            expr: |||
              (
                sum_over_time(obsctl_reloader_prom_rule_fetch_failures_total{%(obsctlReloaderSelector)s}[5m])
              /
                sum_over_time(obsctl_reloader_prom_rule_fetches_total{%(obsctlReloaderSelector)s}[5m])
              ) or vector(0)
              > 0.20
            ||| % $._config,
            'for': '5m',
            labels: {
              severity: 'critical',
            },
            annotations: {
              summary: 'Failing to fetch rules from the local cluster.',
              description: 'obsctl-reloader is failing to fetch rules via the PrometheusRule CRD in the local cluster.',
            },
          },
        ],
      },
    ],
  },
}