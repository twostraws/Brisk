# Ensure they provide a script name
if [ $# -ne 1 ]
    then
        echo "Usage: brisk <script name>"
        exit 1
fi

# Refuse to overwrite existing directories
if [ -e "$1" ]
    then
        echo "Error: the script \"$1\" already exists."
        exit 1
fi

# Copy in our template project
cp -R ~/.brisk/BriskScript "$1"
cd "$1"

# Update Xcode's user data so that it opens the new main.swift file
PWD=`pwd`
sed -i '' "s,PATHTOMAINDOTSWIFT,$PWD\/Sources\/main.swift," .swiftpm/xcode/package.xcworkspace/xcuserdata/username.xcuserdatad/UserInterfaceState.xcuserstate

# Rename our user data to their username, so we open straight to main.swift
USERDATA=".swiftpm/xcode/package.xcworkspace/xcuserdata/"
mv $USERDATA/username.xcuserdatad $USERDATA/`whoami`.xcuserdatad

# And we're all go for Xcode!
xed .
