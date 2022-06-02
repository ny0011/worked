#!/bin/bash

set_global_var() {
    JENKINS_WORKSPACE=${WORKSPACE}
    GIT_WORKSPACE=${WORKSPACE}/${BUILD_NUMBER}
    mkdir -p ${GIT_WORKSPACE}
    GIT_REPOSITORY_NAME=git
    WORKSPACE_TMP=${JENKINS_WORKSPACE}/${BUILD_NUMBER}/${GIT_REPOSITORY_NAME}
    export TOOLS_DIR=${WORKSPACE_TMP}/common/tools
    export H_ROOT=/h/tools
    export L_ROOT=/l/a

    # set_release_var
    RELEASE_IMAGES=RELEASE_IMAGES
    RELEASE_OUT=${RELEASE_IMAGES}/${BUILD_NUMBER}
    RELEASE_FULL_DIR=${JENKINS_WORKSPACE}/${RELEASE_OUT}
    RELEASE_NAME=q-n-h-${BUILD_NUMBER}
    mkdir -p ${RELEASE_FULL_DIR}

    # set error.log
    ERROR_LOG="${JENKINS_WORKSPACE}/error.log"    
}

error_msg(){
    MSG=$1
    EXIT_STATUS=$2

    if [[ "$?" != "0" ]]; then
        echo "ERROR: ${MSG} is failed" >> ${ERROR_LOG}
        if [[ "${EXIT_STATUS}" == "exit" ]]; then
            cat ${ERROR_LOG}
            exit 1
        fi
    fi    
}

git_clone(){
    cd ${GIT_WORKSPACE}
    if [ ${BRANCH} ]; then
        git clone --depth=1 -b ${BRANCH} ssh://git-repository.com/${GIT_REPOSITORY_NAME} 
    else
        git clone --depth=1 ssh://git-repository.com/${GIT_REPOSITORY_NAME}
    fi
    error_msg "git clone" "exit"

    cd ${GIT_REPOSITORY_NAME}
    git branch

    if [ ${PATCH_REF} ]; then
        git fetch ssh://git-repository.com/${GIT_REPOSITORY_NAME} ${PATCH_REF} && git checkout FETCH_HEAD
    fi
    error_msg "git checkout" "exit"
}

set_build_var(){
    # set build dir
    A_BUILD_DIR=a
    B_BUILD_DIR=b
    C_BUILD_DIR=c
    D_BUILD_DIR=d
    E_BUILD_DIR=e
    F_BUILD_DIR=f
    BUILD_DIR_LIST=(${A_BUILD_DIR} ${B_BUILD_DIR} ${C_BUILD_DIR} ${D_BUILD_DIR} ${E_BUILD_DIR})

    # set build cmd
    A_BUILD_CMD="python .a.py"
    B_BUILD_CMD="./b.sh"
    C_BUILD_CMD="python c.py"
    D_BUILD_CMD="python d.py"
    E_BUILD_CMD="python e.py"
    F_BUILD_CMD="python f.py"
    BUILD_CMD_LIST=("A_BUILD_CMD" "B_BUILD_CMD" "C_BUILD_CMD" "D_BUILD_CMD" "E_BUILD_CMD")

}

set_check_build_finished_var(){
    X_DIR=x
    A_DIR=a
    B_DIR=b
    C_DIR=c
    D_DIR=d
    E_DIR=e
    F_DIR=f
    G_DIR=g
    LIST_DIR="${X_DIR} ${A_DIR} ${B_DIR} ${C_DIR} ${D_DIR} ${E_DIR}"

}

x_build(){
    pushd ${X_BUILD_DIR}
    echo "# change workspace due to x build error"
    export WORKSPACE=$WORKSPACE_TMP/x
    echo $WORKSPACE

    echo "## x build started "
    ${X_BUILD_CMD}
    error_msg x
    echo "## x build finished"
    popd

    echo "# change workspace"
    export WORKSPACE=$WORKSPACE_TMP
    echo $WORKSPACE
}

f_build(){
    echo "cd ${F_BUILD_DIR}"
    pushd ${F_BUILD_DIR}
    
    printf "\n## f build started\n"
    ${F_BUILD_CMD}
    error_msg f
    echo "## f build finished"
    popd
}

build(){
    x_build
    set_build_var

    END=`echo ${BUILD_DIR_LIST[@]} | wc -w`
    for ((i=0;i<END;i++)); do
        echo "cd ${BUILD_DIR_LIST[${i}]}"
        pushd ${BUILD_DIR_LIST[${i}]}
        
        REVERSE_NAME=`echo ${BUILD_DIR_LIST[${i}]} | rev`
        BUILD_DIR_NAME=`basename ${REVERSE_NAME} | rev`
        printf "\n## ${BUILD_DIR_NAME} build started\n"
        ${!BUILD_CMD_LIST[${i}]}
        error_msg ${BUILD_DIR_NAME}
        echo "## ${BUILD_DIR_NAME} build finished"        
        popd
    done
    f_build
}

check_build_finished(){
    echo "# All Build is Finished"
    if [ -f "${ERROR_LOG}" ]; then
        cat ${ERROR_LOG}
    fi

    set_check_build_finished_var

    for ITEM_DIR in ${LIST_DIR}; do
        REVERSE_NAME=`echo ${ITEM_DIR} | rev`
        ITEM_NAME=`basename ${REVERSE_NAME} | rev`

        printf "\n# ${ITEM_NAME} output\n"
        ls -al ${ITEM_DIR}
    done

    printf "\n# g output\n"
    ls -al ${G_DIR}

    printf "\n# f output\n"
    ls -al ${F_DIR}
}

move_release_files(){
    pushd ${GIT_WORKSPACE}
    mkdir -p ${RELEASE_OUT}    
    cp ./f ${RELEASE_OUT}
    mv ${RELEASE_OUT}/* ${RELEASE_FULL_DIR}
    popd

    pushd ${RELEASE_FULL_DIR}
    echo "# tar images"
    tar -cf ${RELEASE_NAME}.tar *
    popd
}

release(){
    pushd ${RELEASE_FULL_DIR}
    echo ""
    echo "# release build output : http://release/image/${JOB_NAME}/${BUILD_NUMBER}"
    RELEASE_IP=ip
    POPULATE_HOME=/home/${JOB_NAME}/${BUILD_NUMBER}
    ssh ID@${RELEASE_IP} mkdir -p ${POPULATE_HOME}
    scp -rp ${RELEASE_NAME}.tar ID@${RELEASE_IP}:${POPULATE_HOME}
    popd
}



set_global_var
git_clone
build
check_build_finished
move_release_files
release
