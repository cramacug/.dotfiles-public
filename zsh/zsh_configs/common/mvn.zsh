
mvn_up_minor(){
mvn org.codehaus.mojo:build-helper-maven-plugin:3.5.0:parse-version \
    org.codehaus.mojo:versions-maven-plugin:2.16.2:set \
    -DnewVersion='${parsedVersion.majorVersion}.${parsedVersion.minorVersion}.${parsedVersion.nextIncrementalVersion}' \
    -DgenerateBackupPoms=false}

mvn_up_feature(){
mvn org.codehaus.mojo:build-helper-maven-plugin:3.5.0:parse-version \
    org.codehaus.mojo:versions-maven-plugin:2.16.2:set \
    -DnewVersion='${parsedVersion.majorVersion}.${parsedVersion.nextMinorVersion}.0' \
    -DgenerateBackupPoms=false}

alias mvn_up_minor='mvn_up_minor'
alias mvn_up_feature='mvn_up_feature'
