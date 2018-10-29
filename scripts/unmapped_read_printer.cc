#include <iostream>
#include <fstream>
#include <string>
//#include <string_view>
#include <vector>
#include <cctype>

bool is_digits(const std::string &str)
{
	return str.find_first_not_of("0123456789") == std::string::npos;
}

/*void split(std::string_view& sv, std::vector<string_view>& out) {
	uint16_t prev{0}, idx;
	idx = sv.find_first_of("\t", prev);
	while (idx != -1) {
		out.push_back(sv.substr(prev, idx-prev);
		prev = idx;
		idx = sv.find_first_of("\t", prev);
	}
	out.push_back(sv.substr(prev));
}*/

void split(std::string& sv, std::vector<std::string>& splited) {
	uint16_t prev{0}, idx, cntr{0};
	idx = sv.find_first_of("\t", prev);
	// we only need columns 0, 1, and 9 which are read name, flag, and seq respectively
	while (idx != (uint16_t)-1) {
		if (cntr == 0 or cntr == 1 or cntr == 9) {
			splited.push_back(sv.substr(prev, idx-prev));
			if (cntr == 9) return;
		}
		prev = idx+1;
		idx = sv.find_first_of("\t", prev);
		cntr++;
	}
	splited.push_back(sv.substr(prev));
}


int main(int argc, const char* argv[])
{
    
	std::ifstream infile(std::string(argv[1]), std::ifstream::in);
	std::string line;
	if (!is_digits(argv[2])) {
		std::cerr << "ERRRROOOOORR!! BROKEN!! " << argv[2] << "\n";
	}
	uint64_t maxCntr = std::stoull(argv[2]);
	//std::string pid = argv[3];
	std::ofstream out1(std::string(argv[3])+".1.fa", std::ofstream::out);
	std::ofstream out2(std::string(argv[3])+".2.fa", std::ofstream::out);
	//std::string killPidCommand = "kill " + pid;
	uint64_t cntr{0}, totalcntr{0};
	while (infile.is_open() && infile.good()) {
		/*if (cntr == maxCntr) {
			out1.close();
			out2.close();
			//system(killPidCommand.c_str());
			std::cout << "reached the limit\n";
			std::cout << "total: " << totalcntr << " unmapped: " << cntr << "\n";
			std::exit(0);
		}*/
		std::getline(infile, line);
		if (line.empty() or line[0] == '@') continue;
		std::vector<std::string> splited;
		splited.reserve(30);
		//std::cout << cntr << "\n";
		//std::string_view sv(line);
		//split(sv, out);
		split(line, splited);
		if (splited.size() == 3) {
			if (is_digits(splited[1])) {
				uint64_t flag = std::stoull(splited[1]);
				// is paired, read unmapped, pair unmapped
				if ( ((flag) & 1) and ((flag >> 2) & 1) and ((flag >> 3) & 1) ) {
					if ( (flag >> 6) & 1) // first read
						out1 << ">" << splited[0] << "\n" << splited[2] << "\n";
					else if ( (flag >> 7) & 1) // second read
						out2 << ">" << splited[0] << "\n" << splited[2] << "\n";
					cntr++;
				}
			} else {
				std::cerr << "ERRRRROOOORR!! flag is not a number!! " << splited[1] << "\n";
				std::exit(1);
				
			}
		} else {
			std::cerr << "ERRRRROOOORR!! split BROKENN!! " << splited.size() << "\n";
			std::exit(1);
		}
		totalcntr++;
	}
	out1.close();
	out2.close();
	std::cout << "till the end\n";
	std::cout << "total: " << totalcntr << " unmapped: " << cntr << "\n";

//infile.close();
    return 0;
}

