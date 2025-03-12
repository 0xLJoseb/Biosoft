# ##############################################################################
# NLStradamus FOR DISTRIBUTION
# Copyright Alex Nguyen Ba 2012
#
# LICENCE 
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.

#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.

#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

# ##############################################################################

README file

The use of this text file is to provide the user with basic usage of the c++
standalone of NLStradamus.

BASIC INSTALLATION

Place the cpp file in the desired directory and compile using a c++ compiler:
g++ NLStradamus.cpp -o NLStradamus -O3
for example using gcc.

BASIC USAGE

A list of helpful commands can be accessed by typing :
./NLStradamus -help

A list of arguments used by NLStradamus can be viewed under the -help command,
only one of them being mandatory. 

-i followed by your input file, which is the .fasta file of your proteins of 
interest. An example of this : 

./NLStradamus -i orf_trans.fasta

This will run NLStradamus on the proteins in orf_trans.fasta

-t sets the posterior threshold. The default value of this parameter is 0.6,
but can be set to any value between 0 and 1. The posterior threshold is the 
statistical threshold where the posterior probability should be counted as a
positive hit. An example of this : 

./NLStradamus -i orf_trans.fasta -t 0.7

-m sets the model. The default value of this parameter is 1, which is the
two-state model. This value can take a value of 1 or 2, 2 being the four-state
bipartite model. An example of this : 

./NLStradamus -i orf_trans.fasta -t 0.5 -m 2

The default values are set to the maximal values given by a ROC curve.

OUTPUT

The output of NLStradamus contains the gene ID followed by the predicted sequences.

The graphics and the tables are not output by the PERL/C++ script, but are available
online. 


