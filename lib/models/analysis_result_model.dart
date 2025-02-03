class AnalysisResultModel {
  final String patientName;
  final String age;
  final String gender;
  final String reportContent;
  final String doctorName;
  final String hospital;
  final String hospitalAddress;
  final String reportDate;

  AnalysisResultModel({
    this.patientName = 'Not Available',
    this.age = 'Not Available',
    this.gender = 'Not Available',
    this.reportContent = 'No detailed report available',
    this.doctorName = 'Not Available',
    this.hospital = 'Not Available',
    this.hospitalAddress = 'Not Available',
    this.reportDate = 'Not Specified',
  });

  factory AnalysisResultModel.fromJson(Map<String, dynamic> json) {
    return AnalysisResultModel(
      patientName: json['patientName'] ?? 'Not Available',
      age: json['age'] ?? 'Not Available',
      gender: json['gender'] ?? 'Not Available',
      reportContent: json['reportContent'] ?? 'No detailed report available',
      doctorName: json['doctorName'] ?? 'Not Available',
      hospital: json['hospital'] ?? 'Not Available',
      hospitalAddress: json['hospitalAddress'] ?? 'Not Available',
      reportDate: json['reportDate'] ?? 'Not Specified',
    );
  }
}
