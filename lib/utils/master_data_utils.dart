class MasterDataUtils {
  Map<String, dynamic> districtMasterDataUtil() {
    try {
      [
        {
          "name": "Maharashtra",
          "values": [
            "Mumbai",
            "Pune",
            "Nagpur",
            "Nashik",
            "Thane",
          ],
        },
        {
          "name": "Karnataka",
          "values": [
            "Bangalore",
            "Mysore",
            "Mangalore",
            "Hubli",
            "Belgaum",
          ],
        },
        {
          "name": "Tamil Nadu",
          "values": [
            "Chennai",
            "Coimbatore",
            "Madurai",
            "Salem",
            "Tiruchirappalli",
          ],
        },
        {
          "name": "Uttar Pradesh",
          "values": [
            "Lucknow",
            "Kanpur",
            "Varanasi",
            "Agra",
            "Allahabad",
          ],
        },
        {
          "name": "West Bengal",
          "values": ["Kolkata", "Darjeeling", "Asansol", "Siliguri", "Durgapur"]
        }
      ];
      return {};
    } catch (e) {
      return {};
    }
  }
}
