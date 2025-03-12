// ##############################################################################
// NLStradamus, C++
// Version 1.8
// Alex Nguyen, Copyright 2011
//
// LICENCE 
//
//    This program is free software: you can redistribute it and/or modify
//    it under the terms of the GNU General Public License as published by
//    the Free Software Foundation, either version 3 of the License, or
//    (at your option) any later version.

//    This program is distributed in the hope that it will be useful,
//    but WITHOUT ANY WARRANTY; without even the implied warranty of
//    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//    GNU General Public License for more details.

//    You should have received a copy of the GNU General Public License
//    along with this program.  If not, see <http://www.gnu.org/licenses/>.

// ##############################################################################


using namespace std;

#include <string>
#include <iostream>
#include <fstream>
#include <map>
#include <stdlib.h> 
#include <cstring>
#include <math.h>
#include <vector>
#include <sstream>
#include <limits>

class Sequence {
	
private:
	string m_seq_ID;
	string m_sequence;
public:
	//Setters
	bool appendLine(string seq_line){
		m_sequence += seq_line;
	}
	
	bool setHeader(string header){
		m_seq_ID = header;	
	}
	
	//Getters
	string getHeader(){
		return m_seq_ID;	
	}
	
	string getSequence(){
		return m_sequence;	
	}
};

class Genome {
private:
	int m_genome_size; //Number of sequences	
	map<int , Sequence*> list;
public:
	// Constructor
	Genome(){
		m_genome_size = -1;	
	}
	
	// Getter
	int getGenomeSize(){
		return m_genome_size+1;	
	}
	
	// Main function used.
	bool read_fasta(string fastafile){
		ifstream file;
		file.open(fastafile.c_str(),ifstream::in);
		int i =0;
		if (!file) return 0;
		string gene_name;
		string line;
		while (!file.eof()) {
			getline(file,line);
			if(line.rfind("*")!=string::npos){
				line = line.erase(line.rfind("*"),1);	
			}
			if(line.rfind("\n")!=string::npos){
				line = line.erase(line.rfind("\n"),1);	
			}
			if(line.rfind("\r")!=string::npos){
				line = line.erase(line.rfind("\r"),1);	
			}
			if(line != ""){
				if (line[0] == '>') {
					++m_genome_size;
					string header;
					header = "";
					for(int j = 1;j < line.length();j++){
						header += line[j];	
					}
					list[m_genome_size] = new Sequence;
					list[m_genome_size]->setHeader(header);
				}
				else{
					
					while(line.find_first_not_of("ABCDEFGHIJKLMNPQRSTVWXYZ")!=string::npos){
						line = line.erase(line.find_first_not_of("ABCDEFGHIJKLMNPQRSTVWXYZ"),1);
					}
					
					
					
					if(line.rfind("\n")!=string::npos){
						line = line.erase(line.rfind("\n"),1);	
					}
					if(line.rfind("\r")!=string::npos){
						line = line.erase(line.rfind("\r"),1);	
					}
					//cout.flush();
					
					list[m_genome_size]->appendLine(line);
				}
			}
			
		}
		
		return 1;	
	}
	
	// Grab a child sequence.
	Sequence getSequenceByID(int ID){
		return *list[ID];	
	}
	
	//Delete a child sequence
	void deleteSequenceByID(int ID){
		for(int i = ID;i < m_genome_size;++i){
			//delete[](list[i]);
			list[i] = list[i+1];
		}
		//delete[](list[m_genome_size]);
		list.erase(m_genome_size);
		m_genome_size -= 1;
	}
};


class doubleindex{
public:
	int incsize;
	double* data;
	doubleindex(int sizea, int sizeb){
		incsize = sizea;
		data = new double[sizea*sizeb];
		memset(data,'\0',sizeof(double)*sizea*sizeb);
	}
	~doubleindex(){
	}
	
	double read(int a, int b){return(data[a + b * incsize]);}
	void write(int a, int b, double in ){data[a + b * incsize] =in ;}
	double& operator()(int a, int b){
		return(data[a + b * incsize]);
	}
	
	void clear(){delete[](data);}

};

class singleindex{
public:
	double* data;
	singleindex(int sizea){
		data = new double[sizea];
		memset(data,'\0',sizeof(double)*sizea);
	}
	~singleindex(){
		
	}
	
	double read(int a){return(data[a]);}
	void write(int a, double in){data[a] = in;}
	double& operator()(int a){
		return(data[a]);	
	}
	
	void clear(){delete[](data);}
};

string help(){
	string helpstr;
	helpstr = "You are using NLStradamus v1.8 copyright Alex Nguyen Ba 2011\n";
	helpstr += "-i input file\n";
	helpstr += "-t [optional] Posterior Threshold (0...1) default 0.6\n";
	helpstr += "-m [optional] Model (1 for two state, 2 for four state) default 1\n";
	helpstr += "-a [optional] Algorithm (0 for viterbi, 1 for posterior with threshold, 2 for both) default 1\n";
	helpstr += "-tab [optional] flag for tab delimited output. default is off\n";
	helpstr += "Please read the README_C.txt file for an example\n";
	return(helpstr);	
}
double max_array(double a[], int num_elements){
    double max = a[0];
   
   for (int i=1; i<num_elements; i++)
   {
	 if (a[i]>max)
	 {
	    max=a[i];
	 }
   }
   return(max);
}


int main(int argc, char * argv[]) {
	
	cout.precision(20);
	string fastafile;
	double posterior_threshold = 0.6;
	bool QUIET = 0;
	int ALGORITHM = 1;
	bool NULL_BG = 0;
	
	int count_threshold = 0;
	int MODEL = 1;
	int TAB = 0;
	
	if(argc<2){
		cout << "usage: -i fastafile ... or try -h for more information." << endl;
		return 0;
	}
	string helps ("-help");
	string help_short ("-h");
	string inputs ("-i");
	string thresholds ("-t");
	string algorithms ("-a");
	string models ("-m");
	string tabs ("-tab");
	
	for(int i = 1;i < argc;++i){
		if(argv[i] == inputs){
			fastafile = argv[i+1];
		}
		if(argv[i] == helps){
			cout << help() << endl;
			return 0;
		}
		if(argv[i] == help_short){
			cout << help() << endl;
			return 0;
		}
		if(argv[i] == helps){
			cout << help() << endl;
			return 0;
		}
		if(argv[i] == tabs){
			TAB = 1;	
		}
		if(argv[i] == thresholds){
			posterior_threshold = atof(argv[i+1]);
			if(posterior_threshold <= 0 || posterior_threshold > 1){
				cout << "Posterior threshold must be between 0 and 1." << endl;
				return 0;
			}
		}
		if(argv[i] == algorithms){
			if(atoi(argv[i+1]) == 2){
				ALGORITHM = 2;	
			}
			else if(atoi(argv[i+1]) == 1){
				ALGORITHM = 1;	
			}
			else if(atoi(argv[i+1]) == 0){
				ALGORITHM = 0;	
			}
			else{
				cout << "ALGORITHM must be 0 (Viterbi only), 1 (Posterior only) or 2 (Posterior and Viterbi). Default 1." << endl;
				return 0;
			}
		}
		if(argv[i] == models){
			if(atoi(argv[i+1]) == 2){
				MODEL = 2;	
			}
			else if(atoi(argv[i+1]) == 1){
				MODEL = 1;	
			}
			else{
				cout << "MODEL must be 1 (two-state) or 2 (four-state). Default 1." << endl;
				return 0;
			}
		}
	}
	if(fastafile.length() == 0){ 
		cout << "Requires a fasta file." << endl;
		return 0;
	}
	//###############################################################################
	// Parameters
	// 
	// Parameters for the HMM are arranged as follows: 
	// $e{state}{'emission'} = probability;
	// $a[state_1][state_2] = probability;
	// $begin[state] = probability;
	//
	// Emission probabilities ($e) are the probabilities of emitting something that 
	// is observable.
	//
	// Transition probabilities ($a) are the probabilities of going from one state to
	// another. The synthax is such : $a[from][to] = $probability.
	//
	// Beginning probabilities are the probabilities of being into the state at the
	// first amino acid.
	//
	// STATES ARE ZERO-INDEX
	//###############################################################################
	//map<pair<int,string>, double> e;
	double e[4][26];
	
	e[0][(int)('L' - 'A')] = 0.0950300339227636;
	e[0][(int)('S' - 'A')] = 0.0898291379118776;
	e[0][(int)('K' - 'A')] = 0.0734833177642526;
	e[0][(int)('I' - 'A')] = 0.0655547462377008;
	e[0][(int)('E' - 'A')] = 0.0654254611397116;
	e[0][(int)('N' - 'A')] = 0.0616309263671642;
	e[0][(int)('T' - 'A')] = 0.0591563341467664;
	e[0][(int)('D' - 'A')] = 0.0585263693589517;
	e[0][(int)('V' - 'A')] = 0.0556015083490053;
	e[0][(int)('A' - 'A')] = 0.0549499388896433;
	e[0][(int)('G' - 'A')] = 0.0497648177182998;
	e[0][(int)('R' - 'A')] = 0.0443626210376004;
	e[0][(int)('F' - 'A')] = 0.0441551476044877;
	e[0][(int)('P' - 'A')] = 0.0437563185090993;
	e[0][(int)('Q' - 'A')] = 0.0395581536030419;
	e[0][(int)('Y' - 'A')] = 0.0337842193992118;
	e[0][(int)('H' - 'A')] = 0.0216513102033034;
	e[0][(int)('M' - 'A')] = 0.0208056416313105;
	e[0][(int)('C' - 'A')] = 0.0125821491915738;
	e[0][(int)('W' - 'A')] = 0.0103918470142344;
	
	e[0][(int)('B' - 'A')] = e[0][(int)('D' - 'A')] + e[0][(int)('N' - 'A')];
	e[0][(int)('X' - 'A')] = 1;
	e[0][(int)('Z' - 'A')] = e[0][(int)('E' - 'A')] + e[0][(int)('Q' - 'A')];
	
	e[2][(int)('L' - 'A')] = 0.0950300339227636;
	e[2][(int)('S' - 'A')] = 0.0898291379118776;
	e[2][(int)('K' - 'A')] = 0.0734833177642526;
	e[2][(int)('I' - 'A')] = 0.0655547462377008;
	e[2][(int)('E' - 'A')] = 0.0654254611397116;
	e[2][(int)('N' - 'A')] = 0.0616309263671642;
	e[2][(int)('T' - 'A')] = 0.0591563341467664;
	e[2][(int)('D' - 'A')] = 0.0585263693589517;
	e[2][(int)('V' - 'A')] = 0.0556015083490053;
	e[2][(int)('A' - 'A')] = 0.0549499388896433;
	e[2][(int)('G' - 'A')] = 0.0497648177182998;
	e[2][(int)('R' - 'A')] = 0.0443626210376004;
	e[2][(int)('F' - 'A')] = 0.0441551476044877;
	e[2][(int)('P' - 'A')] = 0.0437563185090993;
	e[2][(int)('Q' - 'A')] = 0.0395581536030419;
	e[2][(int)('Y' - 'A')] = 0.0337842193992118;
	e[2][(int)('H' - 'A')] = 0.0216513102033034;
	e[2][(int)('M' - 'A')] = 0.0208056416313105;
	e[2][(int)('C' - 'A')] = 0.0125821491915738;
	e[2][(int)('W' - 'A')] = 0.0103918470142344;
	
	e[2][(int)('B' - 'A')] = e[2][(int)('D' - 'A')] + e[2][(int)('N' - 'A')];
	e[2][(int)('X' - 'A')] = 1;
	e[2][(int)('Z' - 'A')] = e[2][(int)('E' - 'A')] + e[2][(int)('Q' - 'A')];
	
	
	
	e[1][(int)('L' - 'A')] = 0.0548387096774;
	e[1][(int)('S' - 'A')] = 0.0677419354839;
	e[1][(int)('K' - 'A')] = 0.270967741935;
	e[1][(int)('I' - 'A')] = 0.041935483871;
	e[1][(int)('E' - 'A')] = 0.041935483871;
	e[1][(int)('N' - 'A')] = 0.041935483871;
	e[1][(int)('T' - 'A')] = 0.0306451612903;
	e[1][(int)('D' - 'A')] = 0.0258064516129;
	e[1][(int)('V' - 'A')] = 0.0290322580645;
	e[1][(int)('A' - 'A')] = 0.0516129032258;
	e[1][(int)('G' - 'A')] = 0.0564516129032;
	e[1][(int)('R' - 'A')] = 0.133870967742;
	e[1][(int)('F' - 'A')] = 0.0209677419355;
	e[1][(int)('P' - 'A')] = 0.0564516129032;
	e[1][(int)('Q' - 'A')] = 0.0225806451613;
	e[1][(int)('Y' - 'A')] = 0.0112903225806;
	e[1][(int)('H' - 'A')] = 0.0225806451613;
	e[1][(int)('M' - 'A')] = 0.0112903225806;
	e[1][(int)('C' - 'A')] = 0.00161290322581;
	e[1][(int)('W' - 'A')] = 0.00645161290323;
	
	e[1][(int)('B' - 'A')] = e[1][(int)('D' - 'A')] + e[1][(int)('N' - 'A')];
	e[1][(int)('X' - 'A')] = 1;
	e[1][(int)('Z' - 'A')] = e[1][(int)('E' - 'A')] + e[1][(int)('Q' - 'A')];
	
	e[3][(int)('L' - 'A')] = 0.0548387096774;
	e[3][(int)('S' - 'A')] = 0.0677419354839;
	e[3][(int)('K' - 'A')] = 0.270967741935;
	e[3][(int)('I' - 'A')] = 0.041935483871;
	e[3][(int)('E' - 'A')] = 0.041935483871;
	e[3][(int)('N' - 'A')] = 0.041935483871;
	e[3][(int)('T' - 'A')] = 0.0306451612903;
	e[3][(int)('D' - 'A')] = 0.0258064516129;
	e[3][(int)('V' - 'A')] = 0.0290322580645;
	e[3][(int)('A' - 'A')] = 0.0516129032258;
	e[3][(int)('G' - 'A')] = 0.0564516129032;
	e[3][(int)('R' - 'A')] = 0.133870967742;
	e[3][(int)('F' - 'A')] = 0.0209677419355;
	e[3][(int)('P' - 'A')] = 0.0564516129032;
	e[3][(int)('Q' - 'A')] = 0.0225806451613;
	e[3][(int)('Y' - 'A')] = 0.0112903225806;
	e[3][(int)('H' - 'A')] = 0.0225806451613;
	e[3][(int)('M' - 'A')] = 0.0112903225806;
	e[3][(int)('C' - 'A')] = 0.00161290322581;
	e[3][(int)('W' - 'A')] = 0.00645161290323;
	
	e[3][(int)('B' - 'A')] = e[3][(int)('D' - 'A')] + e[3][(int)('N' - 'A')];
	e[3][(int)('X' - 'A')] = 1;
	e[3][(int)('Z' - 'A')] = e[3][(int)('E' - 'A')] + e[3][(int)('Q' - 'A')];
	
	//Transition frequencies
	double a[4][4];
	double begin[4];
	int current_state;
	if(MODEL == 1){
		a[0][1] = 0.00263746344819678;
		a[0][0] = 1-a[0][1];
		
		a[1][0] = 0.0741935483870968;
		a[1][1] = 1 - a[1][0];
		
		begin[0] = a[0][0];
		begin[1] = a[0][1];
		current_state = 1;
	}
	else{
		a[0][1] = 0.00263746344819678;
		a[0][2] = 0;
		a[0][3] = 0;
		a[0][0] = 1-a[0][1];
		
		a[1][0] = 0;
		a[1][2] = 0.148387096;
		a[1][1] = 1 - a[1][2];
		a[1][3] = 0;
		
		a[2][0] = 0;
		a[2][1] = 0;
		a[2][2] = 0.88028169;
		a[2][3] = 1-a[2][2];
		
		a[3][0] = 0.148387096;
		a[3][1] = 0;
		a[3][2] = 0;
		a[3][3] = 1-a[3][0];
		
		begin[0] = a[0][0];
		begin[1] = a[0][1];
		begin[2] = 0;
		begin[3] = 0;
		current_state = 3;
	}
	
	
	//###############################################################################
	// Handle the input fasta file.
	//###############################################################################
	Genome gen;
	if(!gen.read_fasta(fastafile)){
		cout << "Cannot read the fasta file." << endl;	
		return 0;
	}
	
	//###############################################################################
	// Process
	//###############################################################################
	int total_site_count = 0;
	int length_protein = 0;
	string my_sequence;
	
	if(TAB == 1){
		cout << "#ID	algorithm	score	start	stop	sequence" << endl;
	}
	
	for(int p = 0;p<gen.getGenomeSize();++p){	
		int header_pos = gen.getSequenceByID(p).getHeader().find(" ");
		string header_txt = "";
		if(header_pos != -1){
			header_txt = gen.getSequenceByID(p).getHeader().substr(0,header_pos);
		}
		else{
			header_txt = gen.getSequenceByID(p).getHeader();
		}	
		my_sequence = gen.getSequenceByID(p).getSequence();
		length_protein = my_sequence.length();
		if(length_protein < 1){
			continue;	
		}
		
		doubleindex v = doubleindex(current_state+1,length_protein+1);
		doubleindex f = doubleindex(current_state+1,length_protein+1);	
		doubleindex b = doubleindex(current_state+1,length_protein+1);
		
		singleindex log_fs = singleindex(length_protein+1);
		singleindex log_bs = singleindex(length_protein+1);
		singleindex f_scaling = singleindex(length_protein+1);
		singleindex step = singleindex(length_protein+1);
	
		// Initiation of Viterbi Algorithm
		if(ALGORITHM != 1){
			for(int i = 0;i<=current_state;++i){
				v(i,0) = log(1);	
			}
		}
		
		// Initiation of Forward Algorithm
		for(int i = 0;i<=current_state;++i){
			f(i,0) = 1;	
		}
		
		// Process initiation;
		double log_fs_process = 0;
		double log_bs_process = 0;
		
		//Processing of Viterbi and Forward algorithm : i = amino acids, 1 index.
		
		for(int i = 1;i<=length_protein;++i){
			//Fetch letters
			string next_letter = my_sequence.substr(i-1,1);
			//Go through all the states : j = states. Browse horizontally.
			
			double prev_f = 0;
			for(int j = 0;j <= current_state;++j){
				prev_f = 0;
				double prev_v[current_state+1];
				if(i == 1){
					if(ALGORITHM != 1){
						if(begin[j] != 0){
							prev_v[0] = v(j,i-1) + log(begin[j]);
						}
						else{
							prev_v[0] = -1*pow(10,16);
						}
					}
					f(j,i) = begin[j];
					
				}
				else{
					for(int k = 0;k<=current_state;++k){
						if(ALGORITHM != 1){
							if(a[k][j] != 0){
								prev_v[k] = v(k,i-1) + log(a[k][j]);
							}
							else{
								prev_v[k] = -numeric_limits<float>::infinity();
							}
						}						
						prev_f += (f(k,i-1) * a[k][j]);
					}
					f(j,i) = prev_f;
				}
				// Viterbi maximization
				if(ALGORITHM != 1){
					if(i == 1){
						v(j,i) = prev_v[0];
					}
					else{
						v(j,i) = max_array (prev_v,current_state+1);	
					}
					v(j,i) += log(e[j][next_letter[0]-'A']);
				}
				
				f(j,i) *= e[j][next_letter[0]-'A'];
				f_scaling(i) += f(j,i);
				memset(prev_v,'\0',sizeof(double)*(current_state));
			}
			for(int j = 0;j<=current_state;++j){
				f(j,i) = (f(j,i) / f_scaling(i));
			}
			//Scaling value log sum.
			log_fs_process += log(f_scaling(i));
			log_fs(i) = log_fs_process;	
		}
		//Forward termination
		double P_x = 0;
		for(int k = 0;k<=current_state;++k){
			P_x += f(k,length_protein);
		}
		P_x = log(P_x) + log_fs(length_protein);
		
		// Traceback of viterbi
		
		if(ALGORITHM != 1){
			int maxkey = 0;
			double max_v = v(0,length_protein);
			for(int j = 1;j <= current_state;++j){
				
				if(v(j,length_protein) > max_v){
					maxkey = j;	
				}				
			}
			step(length_protein) = maxkey;
			
			for(int i = length_protein;i >= 1;--i){
				double trace_val;
				double max_trace_val = -numeric_limits<float>::infinity();
				int max_traces = 0;
				for(int k = 0;k <= current_state;++k){
					if(a[k][(int)step(i)] != 0){
						trace_val = v(k,i-1) + log(a[k][(int)step(i)]);	
					}
					else{
						trace_val = -numeric_limits<float>::infinity();	
					}
					if(trace_val > max_trace_val){
						max_trace_val = trace_val;
						max_traces = k;	
					}
				}
				step(i-1) = max_traces;
			}
			
		}
		
		// Initiation of Backward Algorithm [scaled]
		
		for(int k=0;k<=current_state;++k){
			
			b(k,length_protein) = 1.0/f_scaling(length_protein);
		}
		//Implementation of Backward Algorithm
		for(int i = length_protein-1;i>=1;--i){
			string prev_letter = gen.getSequenceByID(p).getSequence().substr(i,1);
			// Scaling values of b
			log_bs_process += log(f_scaling(i+1));
			log_bs(i+1) = log_bs_process;
			
			for(int k = 0;k <= current_state;++k){
				for(int j = 0;j<=current_state;++j){
					b(k,i) += (b(j,i+1) * e[j][prev_letter[0]-'A'] * a[k][j])/f_scaling(i);
				}
			}
		}
		//Termination of scaling values
		log_bs_process += log(f_scaling(1));
		log_bs(1) = log_bs_process;
		
		//Print prediction of viterbi
		string viterbi_string = "";
		if(ALGORITHM != 1){
			
			stringstream o;		
			for(int i = 1;i<=length_protein;++i){
				o << step(i);
				viterbi_string += o.str();
				o.str("");
			}		
		}
		
		//Posterior
		string posterior_string = "";
		double posterior[length_protein+1];
		memset(posterior,'\0',sizeof(double)*(length_protein+1));
		int pmatch = 0;
		if(ALGORITHM != 0){
			// Posterior in Log Space
			for(int i = 1;i <= length_protein;++i){
				int posterior_state = 0;
				
				//#######################################################
				// Set this posterior_state to 0 for 1-BG.
				//#######################################################
				if(f(posterior_state,i) == 0 || b(posterior_state,i) == 0){
					posterior[i] = -1 * pow(10,16);	
				}
				else{
					posterior[i] = log(f(posterior_state,i)) + log_fs(i) + log(b(posterior_state,i)) + log_bs(i) - P_x;
				}
				if(1-exp(posterior[i]) > posterior_threshold){
					posterior_string += "1";	
				}
				else{
					posterior_string += "0";	
				}
				//cout << i << "	" << exp(posterior[i]) << endl;
			}
		
			int i = 0;
			string string_to_find = "1";
			int pos = posterior_string.find("1",i);
			
			int starts[length_protein];
			int stops[length_protein];
			memset(starts,'\0',sizeof(int)*(length_protein));
			memset(stops,'\0',sizeof(int)*(length_protein));
			
			while(posterior_string.find(string_to_find,i) > 0){
				int pos = posterior_string.find(string_to_find,i);
				if(pos == -1) break;
				
				if(string_to_find == "1"){
					starts[pmatch] = pos;
					string_to_find = "0";
				}
				else{
					stops[pmatch] = pos-1;
					string_to_find = "1";
					++pmatch;
				}
				i = pos + 1;	
			}
			
			
			if(posterior_string.find("1",length_protein-1) != string::npos){
				stops[pmatch] = length_protein-1;
				++pmatch;
			}
			
			for(i = 0;i<pmatch;++i){
				
				int length_motif = stops[i] - starts[i] + 1;
				double post[length_motif];
				for(int j = 0;j < length_motif;++j){
					post[j] = 1-exp(posterior[starts[i]+1+j]);	
				}
				double max_in_post = max_array (post,length_motif);
				cout << header_txt << "	";
				cout << "posterior" << "	";
				printf("%.3f",max_in_post);
				cout << "	";
				cout << starts[i]+1 << "	";
				cout << stops[i]+1 << "	" << gen.getSequenceByID(p).getSequence().substr(starts[i],stops[i]-starts[i]+1);
				cout << endl;
				++total_site_count;
			}
		}
		int vmatch = 0;
		if(ALGORITHM!=1){
			int i = 0;
			string string_to_find = "123";
			int pos = viterbi_string.find_first_of("123",i);
			
			int starts[length_protein];
			int stops[length_protein];
			memset(starts,'\0',sizeof(int)*(length_protein));
			memset(stops,'\0',sizeof(int)*(length_protein));
			
			while(viterbi_string.find_first_of(string_to_find,i) > 0){
				int pos = viterbi_string.find_first_of(string_to_find,i);
				if(pos == -1) break;
				
				if(string_to_find == "123"){
					starts[vmatch] = pos;
					string_to_find = "0";
				}
				else{
					stops[vmatch] = pos-1;
					string_to_find = "123";
					++vmatch;
				}
				i = pos + 1;	
			}
			
			
			if(viterbi_string.find_first_of("123",length_protein-1) != string::npos){
				stops[vmatch] = length_protein-1;
				++vmatch;
			}
			
			for(i = 0;i<vmatch;++i){
				
				int length_motif = stops[i] - starts[i] + 1;
				cout << header_txt << "	";
				cout << "viterbi" << "	";
				cout << "	";
				cout << starts[i]+1 << "	";
				cout << stops[i]+1 << "	" << gen.getSequenceByID(p).getSequence().substr(starts[i],stops[i]-starts[i]+1);
				cout << endl;
				
				if(ALGORITHM == 0){
					++total_site_count;	
				}
			}
		}
		if(pmatch > 0 && TAB != 1){
			if(ALGORITHM == 0){
				cout << "Finished analyzing " << header_txt << ". Found " << vmatch << " sites.\n" << endl;
			}
			else{
				cout << "Finished analyzing " << header_txt << ". Found " << pmatch << " sites.\n" << endl;
			}
				
		}
		v.clear();
		f.clear();
		b.clear();
		
		log_fs.clear();
		log_bs.clear();
		f_scaling.clear();
		memset(posterior,'\0',sizeof(double)*(length_protein+1));
		
		step.clear();
	}
	if(TAB != 1){
		cout << "===================================================" << endl;
		cout << "Analyzed "<< gen.getGenomeSize() << " proteins."<<endl;
		cout << total_site_count << " sites were found";
		if(ALGORITHM != 0){
			cout << " using the posterior probability threshold." << endl;
		}
		else{
			cout << " using the viterbi path." << endl;	
		}
		cout << "Input file : " << fastafile << "." << endl;
		cout << "Threshold used : " << posterior_threshold << "." << endl;	
		cout << "===================================================" << endl;
	}
}
