# iPerf3 exporter

The iPerf3 exporter allows iPerf3 probing of endpoints.
This version adds parallelism and retries to <https://github.com/edgard/iperf3_exporter>.

## Running this software

### Using the container image

The container image is available on quay.io:

```bash
podman run --rm -d -p 9579:9579 --name iperf3_exporter quay.io/simonkrenger/iperf3_exporter:latest
```

### Checking the results

Visiting [http://localhost:9579](http://localhost:9579)

## Configuration

iPerf3 exporter is configured via command-line flags.

To view all available command-line flags, run `./iperf3_exporter -h`.

The timeout of each probe is automatically determined from the `scrape_timeout` in the [Prometheus config](https://prometheus.io/docs/operating/configuration/#configuration-file).
This can be also be limited by the `iperf3.timeout` command-line flag. If neither is specified, it defaults to 30 seconds.

## Prometheus Configuration

The iPerf3 exporter needs to be passed the target as a parameter, this can be done with relabelling.
Optional: pass the port that the target iperf3 server is lisenting on as the "port" parameter.
Optional: Set the number of parallel client streams to run as the "parallel" parameter.


Example config:
```yml
scrape_configs:
  - job_name: 'iperf3'
    metrics_path: /probe
    static_configs:
      - targets:
        - foo.server
        - bar.server
    params:
      port: ['5201']
      parallel: ['4']
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9579  # The iPerf3 exporter's real hostname:port.
```

### Querying the bandwidth

You can use the following Prometheus query to get the receiver bandwidth (download speed on measured iperf server) in Mbits/sec:

```
iperf3_received_bytes / iperf3_received_seconds * 8 / 1000000
```

## License

Apache License 2.0, see [LICENSE](https://github.com/edgard/iperf3_exporter/blob/master/LICENSE).
