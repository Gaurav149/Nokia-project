#!/bin/bash

#tb=$1; shift

while getopts ":c:a:i:t:" opt; do
    case ${opt} in
    c) comment=$OPTARG;;
    a) syncall=$OPTARG;;
    i) interval=$OPTARG;;
	t) tag=$OPTARG;;
    esac
done

interval=1 

if [[ $comment == "" ]]; then
	# default comment else add one
	comment = 'test update for bgp unn' 
fi

cd ~/ws/pyshl
source ~/ws/pyshl-infra/venv/bin/activate

if [[ $tag == "" ]]; then 
	tag=unnum
fi 

if [[ $tag == "unnum" ]]; then 
	git diff tests/routing/bgp/unnumbered/
	git diff tests/routing/bgp/library/
fi

if [[ $tag == "csc" ]]; then 
	git diff tests/rtg/library/csc/csc.py
	git diff tests/rtg/infra/test_csc.py
        git diff tests/rtg/library/csc/csc_srl.params
        git diff tests/rtg/library/csc/csc_sr.params
fi 
 	
echo "Review the diff and press c to continue or q to quit" 
read diff
if [[ $diff == "q" ]]; then
    exit
fi

git log
git stash 
sleep $interval
git checkout master
sleep $interval 
git pull
sleep $interval
git checkout wip/gaurav/bgp2
sleep $interval 
git rebase origin/master
sleep $interval 
git stash pop
sleep $interval

if [[ $tag == "unnum" ]]; then 
	git add tests/routing/bgp/unnumbered/config.py
	git add tests/routing/bgp/unnumbered/test_22SRLFID7211.py
	git add tests/routing/bgp/unnumbered/library/commons.py
	git add tests/routing/bgp/library/*
fi 

if [[ $tag == "csc" ]]; then 
	git add tests/rtg/library/*
	git add tests/rtg/infra/test_csc.py
fi 


#git add tests/routing/bgp/rtg/infra/test_rcc.py
git log 
git status 

echo "Do you wish to commit: y/n" 
read commit

if [[ $commit == "y" ]]; then
    git commit -m "${comment}"
	echo "Commit Done"
	
	echo "Do you wish to push to master: y/n" > /dev/tty
	read push
	if [[ $push == "y" ]]; then
		git push --force origin wip/gaurav/bgp2:wip/gaurav/bgp2 -o merge_request.create -o merge_request.merge_when_pipeline_succeeds
	fi
	sleep $interval
else 
	echo " To do it manually :
	source ~/ws/pyshl-infra/venv/bin/activate
	git add tests/routing/bgp/unnumbered/config.py
	git add tests/routing/bgp/unnumbered/test_22SRLFID7211.py
	git commit -m 'test update for bgp unn'
	git push --force origin wip/gaurav/bgp2:wip/gaurav/bgp2 -o merge_request.create -o merge_request.merge_when_pipeline_succeeds
	"
fi
echo " To do it manually :
source ~/ws/pyshl-infra/venv/bin/activate
git add tests/routing/bgp/unnumbered/config.py
git add tests/routing/bgp/unnumbered/test_22SRLFID7211.py
git commit -m 'test update for bgp unn'
git push --force origin wip/gaurav/bgp2:wip/gaurav/bgp2 -o merge_request.create -o merge_request.merge_when_pipeline_succeeds
"



