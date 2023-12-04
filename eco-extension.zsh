#!/bin/zsh

# Support App Extension - SAP Power Monitor
# This script is provided as-is with no implied warranty, feel free to do whatever you'd like with it.
# the example scripts from Root3 B.V. and SAP served as a starting point for this script


appPath="/Applications/Power Monitor.app/Contents/MacOS/Power Monitor"

########## nothing to change below this line ##########

carbonFootprint=-1

if [[ -x "$appPath" ]]; then

	pmOut=$("$appPath" --noGUI & /bin/sleep 2 && kill $! >/dev/null 2>&1)

	if [[ -n "$pmOut" ]]; then

		averagePower=$(/usr/bin/sed -n 's/^Average[^:]*: \([0-9\.]*\).*$/\1/p' <<< "$pmOut")
		countryCode=$(/usr/bin/sed -n 's/^Country[^:]*: \([A-Z]*\).*$/\1/p' <<< "$pmOut")

		if [[ "$averagePower" =~ ^[0-9\.]+$ && -n "$countryCode" ]]; then

			carbonIntensity=$(/usr/bin/sed "1,/########## carbon intensity data ##########/d" "$0" | /usr/bin/sed -n "s/^$countryCode;\(.*\)/\1/p")
	
			if [[ "$carbonIntensity" =~ ^[0-9]+$ ]]; then
	
				# calculate footprint
				calculatedFootprint=$(/usr/bin/bc -l <<< "($averagePower / 1000) * 60 * $carbonIntensity")
				
				# round footprint
				calculatedFootprint=$(echo "scale=0;($calculatedFootprint+0.5)/1" | /usr/bin/bc)

				if [[ "$calculatedFootprint" =~ ^[0-9]+$ && $calculatedFootprint -gt 0 ]]; then
					carbonFootprint="$calculatedFootprint"
				fi
	
			fi
		fi

	fi
fi

echo "<result>$carbonFootprint</result>"

# ---------------------    do not edit below this line    ----------------------

# Support App preference plist
preference_file_location="/Library/Preferences/nl.root3.support.plist"

# Start spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool true

# Replace value with placeholder while loading
defaults write "${preference_file_location}" ExtensionValueB -string "Carbon Footprint"

# Keep loading effect active for 0.5 seconds
sleep 0.5

# Write output to Support App preference plist
defaults write "${preference_file_location}" ExtensionValueB -string "${carbonFootprint}g CO2eq/h"

# Stop spinning indicator
defaults write "${preference_file_location}" ExtensionLoadingB -bool false

exit 0

########## carbon intensity data ##########

AE;162
AR;196
AU;246
AT;157
AZ;210
BE;126
BD;203
BG;196
BY;194
BR;140
CA;141
CH;117
CL;185
CN;262
CO;172
CY;255
CZ;208
DE;192
DK;159
DZ;257
EC;195
EG;237
ES;150
EE;159
FI;117
FR;117
GB;174
GR;192
HK;130
HR;178
HU;172
ID;268
IN;275
IE;215
IR;221
IQ;315
IS;58
IL;187
IT;186
JP;217
KZ;350
KR;176
KW;220
LK;196
LT;198
LU;199
LV;172
MA;266
MX;216
MK;236
MY;220
NL;146
NO;72
NZ;145
OM;194
PK;214
PE;169
PH;265
PL;266
PT;154
QA;179
RO;204
RU;202
SA;224
SG;34
SK;179
SI;167
SE;57
TH;196
TM;186
TT;212
TR;235
TW;205
UA;218
US;194
UZ;222
VE;141
VN;272
ZA;315



