#!/bin/bash
function exit_if_fail {
    command=$@
    echo "Executing '$command'"
    eval $command
    rc=$?
    if [ $rc -ne 0 ]; then
        echo "'$command' returned $rc."
        exit $rc
    fi
}

cd /home/ubuntu/.go_workspace/src/github.com/grafana/grafana

rm -rf node_modules
npm install -g yarn
yarn install --pure-lockfile

exit_if_fail npm test

echo "running go fmt"
exit_if_fail test -z "$(gofmt -s -l ./pkg | tee /dev/stderr)"

echo "running go vet"
exit_if_fail test -z "$(go vet ./pkg/... | tee /dev/stderr)"

exit_if_fail go run build.go build
exit_if_fail go test -v ./pkg/...


