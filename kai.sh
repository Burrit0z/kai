rm -f /opt/simject/kai.dylib
cp -v .dragon/_/Library/MobileSubstrate/DynamicLibraries/kai.dylib /opt/simject/kai.dylib
codesign -f -s - /opt/simject/kai.dylib
cp -v .dragon/_/Library/MobileSubstrate/DynamicLibraries/kai.plist /opt/simject
/Users/carsonzielinski/simject/bin/resim