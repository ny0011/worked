#!/bin/bash

# isTChanged : Jenkins Boolean Parameter

echo "pwd : `pwd`"
printf "Is T Changed? $isTChanged\n\n"

git clone t 
cd t
printf "### git pull & git submodule update ###\n"
git pull --rebase 

if [[ $isTChanged == false ]]; then
	git submodule init && git submodule update --remote 
	DIFF=`git status -s`
	if [[ $DIFF != '' ]]; then
		  printf "\n### T COMMIT ###\n"
	    pushd tests && LOG=`git log --pretty=oneline -1 | cut -c 42-100`
		  popd
      echo $LOG

		  COMMIT='[AUTO-T] '$LOG
		  git add . && git commit -m "$COMMIT"  && git push origin main
	else
    	printf "\n## note: Notting to change. Exited ##\n"
    	exit
	fi
else
	printf "\n## note: T is changed. Continue ##\n"
fi

printf "### Build is started ###\n"
cd ..
sudo make -C t docker

printf "### Build is finished ###\n"
PACKAGE=$(ls | grep deb)
echo ${PACKAGE}

if [ ${#PACKAGE} != 0 ]; then
        echo "### copy image to server ###"
        scp -P 5000 -v t.deb t_all.deb  user@IP1:~/
        scp -v t.deb t_all.deb  r@IP2:~/volume
        scp -v t.deb t_all.deb  r@IP3:~/volume

        printf "### install package ###\n"
        echo "### IP1 ###"
        ssh IP1 -l user -p 5000 "sudo dpkg -i t.deb t_all.deb "
        echo "### IP2 ###"
        ssh IP2 "sudo docker exec t sh -c 'cd /volume; dpkg -i t.deb t_all.deb '"
        echo "### IP3 ###"
        ssh IP3 "sudo docker exec t sh -c 'cd /volume; dpkg -i t.deb t_all.deb '"
else
	echo "## error: deb package is not available. ##"
  exit
fi
