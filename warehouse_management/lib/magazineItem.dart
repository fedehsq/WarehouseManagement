import 'package:intl/intl.dart';

class MagazineItem {
 String urgency;
 String note;
 String description;
 String estarCode;
 String mag;
 String barCode;
 String ref;
 String product;
 String category;
 String threshold;
 String quantity;
 String photoLink;
 String deadline;
 String lastCheck;
 String discharges;
 String check;
 String charges;
 String owner;
 String missingName;
 String monthlyConsumption;

 MagazineItem(
      this.urgency,
      this.note,
      this.description,
      this.estarCode,
      this.mag,
      this.barCode,
      this.ref,
      this.product,
      this.category,
      this.threshold,
      this.quantity,
      this.photoLink,
      this.deadline,
      this.lastCheck,
      this.discharges,
      this.check,
      this.charges,
      this.owner,
      this.missingName,
      this.monthlyConsumption) {
  if (this.photoLink.isNotEmpty) {
   // link can starts with different strings
   if (this.photoLink.startsWith("https://drive.google.com/file/d/")) {
    // extract id
    // https://drive.google.com/file/d/1NBgTla6Z0Q1fZq2vNsUukSv6bWUbA-fp/view?usp=sharing
    String id = this.photoLink.split('d/')[1];
    id = id.split('/view')[0];
    this.photoLink = 'https://drive.google.com/uc?export=view&id=' + id;
   } else if (this.photoLink.startsWith("https://drive.google.com/open?")) {
    // https://drive.google.com/open?id=1xMV-mV_XAC4hzVtK5_KvmWFTQs7zzCNS
    String id = this.photoLink.split('open?id=')[1];
    this.photoLink = 'https://drive.google.com/uc?export=view&id=' + id;
   } else {
    // set as non photo item
    this.photoLink = '';
   }
  }

   // total seconds - 2.209.161.600(seconds between windows and unix)
   // extract days and convert to seconds
  if (this.deadline.isNotEmpty) {
   int windowsSeconds = int.parse(this.deadline) * 24 * 3600;
   int unixTimestamp = windowsSeconds - 2209161600;
   DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
   this.deadline = DateFormat('dd/MM/yyyy').format(date);
  }

  if (this.lastCheck.isNotEmpty) {
   if (this.lastCheck.contains('.')) {
    int windowsSeconds = int.parse(this.lastCheck.split('.')[0]) * 24 * 3600;
    int unixTimestamp = windowsSeconds - 2209161600;
    DateTime date = DateTime.fromMillisecondsSinceEpoch(unixTimestamp * 1000);
    this.lastCheck = DateFormat('dd/MM/yyyy').format(date);
   }
  }

 }

 toFilteredList() {
  return [
   this.owner,
   this.category,
   this.product,
   this.estarCode,
   this.mag,
   this.threshold,
   this.quantity,
   this.deadline,
   this.lastCheck,
   /*
   this.urgency
   this.note,
   this.description,
   this.barCode,
   this.ref,
   this.photoLink,
   this.discharges,
   this.check,
   this.charges,
   this.missingName,
   this.monthlyConsumption
    */
  ];
 }

 toList() {
  return [
   this.urgency,
   this.note,
   this.description,
   this.estarCode,
   this.mag,
   this.barCode,
   this.ref,
   this.product,
   this.category,
   this.threshold,
   this.quantity,
   this.photoLink,
   this.deadline,
   this.lastCheck,
   this.discharges,
   this.check,
   this.charges,
   this.owner,
   this.missingName,
   this.monthlyConsumption
  ];
 }

}
