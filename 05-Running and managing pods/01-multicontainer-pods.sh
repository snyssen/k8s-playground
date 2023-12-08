#! /usr/bin/bash
# shellcheck disable=SC2317

# Create a multicontainers pod
k apply -f 01-multicontainer-pod.yaml
# Go into container (not specifying a name makes us go into the first declared container)
k exec -it multicontainer-pod -- /bin/sh
# And observe that index.html is getting written to
tail /var/log/index.html
exit
# Now connect to the second container by specifying its name
k exec -it multicontainer-pod --container consumer -- /bin/sh
# And observe that data written in first container is accessible in this one too
tail /usr/share/nginx/html/index.html
exit

# We can also see that nginx publish that data
k port-forward multicontainer-pod 8080:80 &
curl http://localhost:8080
fg
# then ctrl+c to close