import os
import json
import csv
import sys

def parse_json_logs(input_directory, output_csv):
    log_files = [f for f in os.listdir(input_directory) if f.endswith('.json')]
    
    if not log_files:
        print("No JSON log files found in the directory.")
        return
    
    data_list = []
    for log_file in log_files:
        log_path = os.path.join(input_directory, log_file)
        
        with open(log_path, 'r', encoding='utf-8') as file:
            try:
                log_data = json.load(file)
                if isinstance(log_data, dict):
                    extracted_data = {
                        'instance': log_file.removesuffix(".json"),
                        'termination_reason': log_data.get('termination_reason', ''),
                        'iteration_count': log_data.get('iteration_count', ''),
                        'solve_time_sec': log_data.get('solve_time_sec', ''),
                        "cumulative_kkt_matrix_passes": log_data["solution_stats"]["cumulative_kkt_matrix_passes"],
                        'preprocessing_time_sec': log_data.get('preprocessing_time_sec', ''),
                        'cumulative_rejected_steps': log_data["solution_stats"]["cumulative_rejected_steps"],
                    }
                    data_list.append(extracted_data)
                else:
                    print(f"Skipping {log_file}: JSON content is not a dictionary.")
            except json.JSONDecodeError:
                print(f"Skipping {log_file}: Invalid JSON format.")
    
    fieldnames = ['instance', 'termination_reason', 'iteration_count', 'solve_time_sec', 
                  'cumulative_kkt_matrix_passes', 'preprocessing_time_sec', 'cumulative_rejected_steps']
    
    with open(output_csv, 'w', newline='', encoding='utf-8') as csvfile:
        writer = csv.DictWriter(csvfile, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(data_list)
    
    print(f"CSV file '{output_csv}' has been created successfully.")

if __name__ == "__main__":
    input_directory = sys.argv[1]
    output_csv = sys.argv[2]
    parse_json_logs(input_directory, output_csv)