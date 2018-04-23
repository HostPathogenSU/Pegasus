#!/bin/bash
#This is to install all the dependencies
#o do, check if htslib comes with samtools when using apt-get


###specific dirs
#requires python 2.7
#requires java
#trim="${master_dir}/programs/Trimmomatic-0.36/trimmomatic-0.36.jar"										works
#trim_PE="${master_dir}/programs/Trimmomatic-0.36/adapters/TruSeq2-PE.fa"									works
#TBprofiler_path="${master_dir}/programs/TBProfiler/tb-profiler"											perhaps remove this
#picard="${master_dir}/programs/build/libs/picard.jar"														this file path will change NB
#gatk="${master_dir}/programs/GenomeAnalysisTK.jar"															still a problem
#lumpy_extract_splitters="${master_dir}/programs/lumpy-sv/scripts/extractSplitReads_BwaMem"					double check path			
#lumpy_vcftobed="${master_dir}/programs/lumpy-sv/scripts/vcfToBedpe"										works
#export PATH=$PATH:"${master_dir}/programs/bwa"																works																						
#export PATH=$PATH:"${master_dir}/programs/novocraft"														drequired manual download
#export PATH=$PATH:"${master_dir}/programs/lumpy-sv"														issue with make
#export PATH=$PATH:"${master_dir}/programs/svtyper-master"													required manual download
#export PATH=$PATH:"${master_dir}/programs/FastQC"															required manual download
#export PATH=$PATH:"${master_dir}/programs/SOAPdenovo2"														works
#export PATH=$PATH:"${master_dir}/programs/svprops/src/"
#export PATH=$PATH:"${master_dir}/programs/samblaster"

###############################################################
#force super user for this 
if [ $(id -u) != "0" ]; then
echo "You must be the superuser to run this script" >&2
echo "type: sudo bash install.sh" >&2
exit 1
fi

#Install dir
install_dir=$(pwd "$0")

#set up environment
programs="${install_dir}/programs"

mkdir "${programs}" 
chmod 777 "${programs}"
###########################################################################################
#phase I installation
###########################################################################################
#create array with files able to install with apt-get
declare -a arr1=("yad" "curl" "samtools" "bcftools" 
				 "sra-toolkit" "wget" "vcftools"
				 "abacas" "git" "pip")

#loop over array
for i in "${arr1[@]}";
do
	#installing package finder if neccesary
	echo "checking for package searcher"
		if ! [ -x "$(command -v dpkg)" ];
			then
				echo "installing dpkg"
				apt-get -y install dpkg
			else
				echo "dpkg found in the system"
		fi
	
	#start EZ package installation
	echo "installing ${i}"
	#package search
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' ${i}|grep "install ok installed")
		if [ "" == "$PKG_OK" ]; 
		then
			echo "Installing ${i}"
			apt-get -y install "${i}"
		else
			echo "${i} is already installed in the correct location"
		fi
	
done
#installing other dependencies i.e. that requires download
#check internet connection

wget -q --spider http://google.com

if [ $? -eq 0 ]; then
    echo "internet online"
else
    echo "internet connection required for install, aborting the installation process"
	exit 1
fi

#installing trimmomatic
trimmo_install() {
					cd "${programs}"
					echo "installing trimmomatic"
					curl -O http://www.usadellab.org/cms/uploads/supplementary/Trimmomatic/Trimmomatic-0.36.zip
					unzip Trimmomatic-0.36.zip
					cd "${install_dir}"
				}
#install picard
picard_install () {
					cd "${programs}"
					echo "Installing picard"
					git clone https://github.com/broadinstitute/picard.git
					cd picard/
					./gradlew shadowJar
					cd "${install_dir}"
				}
				
#install gatk NBNBNBNB problematic
#install lumpy
lumpy_install() {
					cd "${programs}"
					echo "Installing lumpy"
					git clone --recursive https://github.com/arq5x/lumpy-sv.git
					cd lumpy-sv
					make 
					cd "${install_dir}"
				}
#install bwa 0.7.12
bwa_install () {
				cd "${programs}"
				echo "Installing BWA"
				git clone --recursive https://github.com/lh3/bwa.git
				cd bwa
				make
				cd "${install_dir}"
				}

#install delly/src/
delly_install () {
					cd "${programs}"
					echo "Installing delly"
					git clone --recursive https://github.com/dellytools/delly.git
					cd delly
					make all
					cd "${install_dir}"
				}
#SOAPdenovo2				
soap_install () {
					cd "${programs}"
					echo "Installing SOAPdenovo2"
					git clone --recursive https://github.com/aquaskyline/SOAPdenovo2.git
					cd SOAPdenovo2
					make 
					cd "${install_dir}"
				}
				
svprops_install () {
					cd "${programs}"
					echo "Installing SVprops"
					git clone --recursive https://github.com/dellytools/svprops.git
					cd svprops/
					make all
					cd "${install_dir}"
					}

samblaster_install () {
						cd "${programs}"
						echo "Installing Samblaster"
						git clone git://github.com/GregoryFaust/samblaster.git
						cd samblaster
						make
						cd "${install_dir}"
					}
					
trimmo_install
picard_install					
lumpy_install
bwa_install
delly_install
soap_install
svprops_install
samblaster_install

echo "changing write permissions"
declare -a arr2=("lumpy-sv" "picard" "trimmomatic-0.36" "delly" "bwa" "SOADPdenovo2" "svprops" "samblaster")

#change permissions
for a in "${arr2[@]}";
do
	echo "changing permissions"
	chmod 777 "${a}"
done

echo "installation complete"

startup=$(yad --item-separator="," --separator="\t" \
	--title="Pegasus v1.0" \
	--form \
	--text="Thank you for downloading Pegasus" \
	--field="Launch GUI":CHK \
	--field="Launch Terminal":CHK)

echo "${startup}" > temp.txt

GUI=$(cat temp.txt | awk '{print $1}')
echo "${GUI}"

term=$(cat temp.txt | awk '{print $2}')
echo "${term}"

chmod 755 pegasus.sh
chmod 755 pegasusGUI.sh

if [[ "${GUI}" == TRUE ]];
then
	echo "Launching gui"
	./frontend.sh
fi

if [[ "${term}" == TRUE ]];
then
	echo "launching terminal"
	./main.sh
fi

rm ./temp.txt
exit 0









