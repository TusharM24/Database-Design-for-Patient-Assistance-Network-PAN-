import java.io.*;
import java.sql.*;
import java.util.Scanner;
import java.sql.Connection;
import java.sql.Statement;
import java.util.Scanner;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.CallableStatement;

public class task5 {

    // Database credentials and connection URL for Azure SQL
    final static String HOSTNAME = "mhat0000-sql-server.database.windows.net";
    final static String DBNAME = "cs-dsa-4513-sql-db";
    final static String USERNAME = "mhat0000";
    final static String PASSWORD = "LionelMessi@24";
    final static String URL = String.format("jdbc:sqlserver://%s:1433;database=%s;user=%s;password=%s;encrypt=true;trustServerCertificate=false;hostNameInCertificate=*.database.windows.net;loginTimeout=30;", HOSTNAME, DBNAME, USERNAME, PASSWORD);

    // Scanner for user input
    final static Scanner sc = new Scanner(System.in);

    public static void main(String[] args) {
        System.out.println("WELCOME TO THE PATIENT ASSISTANT NETWORK DATABASE SYSTEM");
        String option = "";

        while (!option.equals("18")) {
            System.out.println("\nPlease select an option:");
            System.out.println("1. Enter a new team into the database");
            System.out.println("2. Enter a new client into the database and associate him or her with one or more teams");
            System.out.println("3. Enter a new volunteer into the database and associate him or her with one or more teams");
            System.out.println("4. Enter the number of hours a volunteer worked this month for a particular team");
            System.out.println("5. Enter a new employee into the database and associate him or her with one or more teams");
            System.out.println("6. Enter an expense charged by an employee");
            System.out.println("7. Enter a new donor and associate him or her with several donations");
            System.out.println("8. Retrieve the name and phone number of the doctor of a particular client");
            System.out.println("9. Retrieve the total amount of expenses charged by each employee for a particular period of \n"
            		+ "time. The list should be sorted by the total amount of expenses");
            System.out.println("10. Retrieve the list of volunteers that are members of teams that support a particular client");
            System.out.println("11. Retrieve the names of all teams that were founded after a particular date");
            System.out.println("12. Retrieve the names, social security numbers, contact information, and emergency contact\n"
            		+ "information of all people in the database");
            System.out.println("13. Retrieve the name and total amount donated by donors that are also employees and indicate \n"
            		+ "if each donor wishes to remain anonymous");
            System.out.println("14. Increase the salary by 10% of all employees to whom more than one team must report.");
            System.out.println("15. Delete all clients who do not have health insurance and whose value of importance for \n"
            		+ "transportation is less than 5");
            System.out.println("16. Import: enter new teams from a data file");
            System.out.println("17. Export: retrieve and export names and mailing addresses of people on the mailing list");
            System.out.println("18. Quit");
            System.out.print("Your choice: ");
            option = sc.next();

            try {
                switch (option) {
                    case "1":
                        add_New_Team();
                        break;
                    case "2":
                        add_New_Client();
                        break;
                    case "3":
                        add_New_Volunteer();
                        break;
                    case "4":
                        add_number_of_hours();
                        break;
                    case "5":
                        add_New_Employee();
                        break;
                    case "6":
                        add_Employee_Expenses();
                        break;
                    case "7":
                        add_New_Donor_With_Donations();
                        break;
                    case "8":
                        get_Doctor_details();
                        break;
                    case "9":
                        get_Total_Expenses();
                        break;
                    case "10":
                        get_Volunteers_list();
                        break;
                    case "11":
                        get_Teams_list();
                        break;
                    case "12":
                        get_All_People_details();
                        break;
                    case "13":
                        get_Employee_Donors();
                        break;
                    case "14":
                        increase_Salary();
                        break;
                    case "15":
                        delete_Clients_With_no_Health_Insurance();
                        break;
                    case "16":
                        import_Teams_From_File();
                        break;
                    case "17":
                        export_Mailing_List();
                        break;
                    case "18":
                        System.out.println("Quitting...");
                        break;
                    default:
                        System.out.println("Invalid option. Please try again.");
                        break;
                }
            } catch (SQLException e) {
                System.out.println("An error occurred while accessing the database:");
                e.printStackTrace();
            } catch (IOException e) {
                System.out.println("An error occurred with file operations:");
                e.printStackTrace();
            }
        }
        sc.close();
    }

    // Option 1: Enter a new team into the database
    public static void add_New_Team() throws SQLException {
        System.out.println("Enter Team Name:");
        sc.nextLine(); // Consume newline
        String name = sc.nextLine();
        System.out.println("Enter Team Type:");
        String type = sc.nextLine();
        System.out.println("Enter Date Formed (YYYY-MM-DD):");
        String dateFormed = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewTeam(?, ?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, name);
                stmt.setString(2, type);
                stmt.setDate(3, Date.valueOf(dateFormed));
                stmt.execute();
                System.out.println("Team added successfully.");
            }
        }
    }

    // Option 2: Enter a new client and associate with teams
    public static void add_New_Client() throws SQLException {
        System.out.println("Enter Client SSN:");
        sc.nextLine(); // Consume newline
        String ssn = sc.nextLine();
        System.out.println("Enter Name:");
        String name = sc.nextLine();
        System.out.println("Enter Gender (M/F):");
        String gender = sc.nextLine();
        System.out.println("Enter Profession:");
        String profession = sc.nextLine();
        System.out.println("Enter Mailing Address:");
        String mailingAddress = sc.nextLine();
        System.out.println("Enter Email Address:");
        String emailAddress = sc.nextLine();
        System.out.println("Enter Phone Number:");
        String phoneNumber = sc.nextLine();
        System.out.println("Enter Doctor Name:");
        String doctorName = sc.nextLine();
        System.out.println("Enter Doctor Phone Number:");
        String doctorPhone = sc.nextLine();
        System.out.println("Enter Assigned Date (YYYY-MM-DD):");
        String assignedDate = sc.nextLine();
        System.out.println("Enter Team Names (comma-separated):");
        String teamNames = sc.nextLine();
        System.out.println("Is the person on mailing list:(True/False)");
        boolean mailinglist = sc.nextBoolean();
        System.out.println("Is the person active on team:(True/False)");
        boolean Status = sc.nextBoolean();
        

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewClient(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, mailingAddress);
                stmt.setString(6, emailAddress);
                stmt.setString(7, phoneNumber);
                stmt.setString(8, doctorName);
                stmt.setString(9, doctorPhone);
                stmt.setDate(10, Date.valueOf(assignedDate));
                stmt.setString(11, teamNames);
                stmt.setBoolean(12, mailinglist);
                stmt.setBoolean(13, Status);
                stmt.execute();
                System.out.println("Client added and associated with teams successfully.");
            }
        }
    }
    // Option 3: Enter a new volunteer and associate with teams
    public static void add_New_Volunteer() throws SQLException {
        System.out.println("Enter Volunteer SSN:");
        sc.nextLine(); // Consume newline
        String ssn = sc.nextLine();
        System.out.println("Enter Name:");
        String name = sc.nextLine();
        System.out.println("Enter Gender (M/F):");
        String gender = sc.nextLine();
        System.out.println("Enter Profession:");
        String profession = sc.nextLine();
        System.out.println("Enter Mailing Address:");
        String mailingAddress = sc.nextLine();
        System.out.println("Enter Email Address:");
        String emailAddress = sc.nextLine();
        System.out.println("Enter Phone Number:");
        String phoneNumber = sc.nextLine();
        System.out.println("Enter Join Date (YYYY-MM-DD):");
        String joinDate = sc.nextLine();
        System.out.println("Enter Training Date (YYYY-MM-DD):");
        String trainingDate = sc.nextLine();
        System.out.println("Enter Training Location:");
        String trainingLocation = sc.nextLine();
        System.out.println("Enter Team Names (comma-separated):");
        String teamNames = sc.nextLine();
        System.out.println("Is the person on mailing list:(True/False)");
        boolean mailinglist = sc.nextBoolean();
        System.out.println("Is the person active on team:(True/False)");
        boolean Status = sc.nextBoolean();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewVolunteer(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, mailingAddress);
                stmt.setString(6, emailAddress);
                stmt.setString(7, phoneNumber);
                stmt.setDate(8, Date.valueOf(joinDate));
                stmt.setDate(9, Date.valueOf(trainingDate));
                stmt.setString(10, trainingLocation);
                stmt.setString(11, teamNames);
                stmt.setBoolean(12, mailinglist);
                stmt.setBoolean(13, Status);
                stmt.execute();
                System.out.println("Volunteer added and associated with teams successfully.");
            }
        }
    }

 // Option 4: Enter volunteer hours worked for a team for a specific month
    public static void add_number_of_hours() throws SQLException {
        System.out.println("Enter Team Name:");
        sc.nextLine(); // Consume newline
        String teamName = sc.nextLine();
        System.out.println("Enter Volunteer SSN:");
        String volunteerSSN = sc.nextLine();
        System.out.println("Enter Hours Worked:");
        int hoursWorked = sc.nextInt();
        sc.nextLine(); // Consume newline
        System.out.println("Enter Month (e.g., 'January'):");
        String month = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddVolunteerHours(?, ?, ?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                // Set parameters for the stored procedure
                stmt.setString(1, teamName);
                stmt.setString(2, volunteerSSN);
                stmt.setInt(3, hoursWorked);
                stmt.setString(4, month);  // Pass month name directly

                stmt.execute();
                System.out.println("Volunteer hours added successfully for the specified month.");
            } catch (SQLIntegrityConstraintViolationException e) {
                System.out.println("Error: An entry with the same Team Name, Volunteer SSN, and Month already exists.");
            } catch (SQLException e) {
                e.printStackTrace();
                System.out.println("An error occurred while adding volunteer hours.");
            }
        }
    }




   
 // Option 5: Enter a new employee and associate with teams
    public static void add_New_Employee() throws SQLException {
        System.out.println("Enter Employee SSN:");
        sc.nextLine(); // Consume newline
        String ssn = sc.nextLine();
        System.out.println("Enter Name:");
        String name = sc.nextLine();
        System.out.println("Enter Gender (M/F):");
        String gender = sc.nextLine();
        System.out.println("Enter Profession:");
        String profession = sc.nextLine();
        System.out.println("Enter Mailing Address:");
        String mailingAddress = sc.nextLine();
        System.out.println("Enter Email Address:");
        String emailAddress = sc.nextLine();
        System.out.println("Enter Phone Number:");
        String phoneNumber = sc.nextLine();
        System.out.println("Enter Salary:");
        double salary = sc.nextDouble();
        sc.nextLine(); // Consume newline
        System.out.println("Enter Marital Status:");
        String maritalStatus = sc.nextLine();
        System.out.println("Enter Hiring Date (YYYY-MM-DD):");
        String hiringDate = sc.nextLine();
        System.out.println("Enter Team Names (comma-separated):");
        String teamNames = sc.nextLine();
        System.out.println("Is the person on mailing list:(True/False)");
        boolean mailinglist = sc.nextBoolean();
        sc.nextLine();
        System.out.println("Enter Description");
        String Description = sc.nextLine();
        System.out.println("Enter Reporting Date (YYYY-MM-DD):");
        String reportDate = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewEmployee(?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?,?,?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, mailingAddress);
                stmt.setString(6, emailAddress);
                stmt.setString(7, phoneNumber);
                stmt.setDouble(8, salary);
                stmt.setString(9, maritalStatus);
                stmt.setDate(10, Date.valueOf(hiringDate));
                stmt.setString(11, teamNames);
                stmt.setBoolean(12, mailinglist);
                stmt.setString(13, Description);
                stmt.setString(14, reportDate);
                stmt.execute();
                System.out.println("Employee added and associated with teams successfully.");
            }
        }
    }

    // Option 6: Enter an employee expense
    public static void add_Employee_Expenses() throws SQLException {
        System.out.println("Enter Employee SSN:");
        sc.nextLine(); // Consume newline
        String employeeSSN = sc.nextLine();
        System.out.println("Enter Expense Date (YYYY-MM-DD):");
        String expenseDate = sc.nextLine();
        System.out.println("Enter Amount:");
        double amount = sc.nextDouble();
        sc.nextLine(); // Consume newline
        System.out.println("Enter Description:");
        String description = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddEmployeeExpense(?, ?, ?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, employeeSSN);
                stmt.setDate(2, Date.valueOf(expenseDate));
                stmt.setDouble(3, amount);
                stmt.setString(4, description);
                stmt.execute();
                System.out.println("Employee expense recorded successfully.");
            }
        }
    }

    // Option 7: Enter a new donor and associate with donations
    public static void add_New_Donor_With_Donations() throws SQLException {
        System.out.println("Enter Donor SSN:");
        sc.nextLine(); // Consume newline
        String ssn = sc.nextLine();
        
        System.out.println("Enter Name:");
        String name = sc.nextLine();
        System.out.println("Enter Gender (M/F):");
        String gender = sc.nextLine();
        System.out.println("Enter Profession:");
        String profession = sc.nextLine();
        System.out.println("Enter Mailing Address:");
        String mailingAddress = sc.nextLine();
        System.out.println("Enter Email Address:");
        String emailAddress = sc.nextLine();
        System.out.println("Enter Phone Number:");
        String phoneNumber = sc.nextLine();
        System.out.println("Is Donor on the mailing list? (true/false):");
        boolean mailingList = sc.nextBoolean();
        sc.nextLine(); // Consume newline
        
        System.out.println("Is Donor Anonymous? (true/false):");
        boolean anonymous = sc.nextBoolean();
        sc.nextLine(); // Consume newline

        // Collect donations
        System.out.println("Enter number of donations to add:");
        int numDonations = sc.nextInt();
        sc.nextLine(); // Consume newline

        StringBuilder donationsJson = new StringBuilder("[");
        for (int i = 0; i < numDonations; i++) {
            System.out.println("Enter Donation Date (YYYY-MM-DD):");
            String date = sc.nextLine();
            System.out.println("Enter Amount:");
            double amount = sc.nextDouble();
            sc.nextLine(); // Consume newline
            System.out.println("Enter Donation Type (Cheque or Credit Card):");
            String donationType = sc.nextLine();
            System.out.println("Enter Campaign Name:");
            String campaignName = sc.nextLine();

            // If donation is by cheque, prompt for Cheque_No
            String chequeNo = "";
            String cardNumber = "";
            String cardType = "";
            String expiryDate = "";

            if ("Cheque".equalsIgnoreCase(donationType)) {
                System.out.println("Enter Cheque Number:");
                chequeNo = sc.nextLine();
            } else if ("Credit Card".equalsIgnoreCase(donationType)) {
                System.out.println("Enter Card Number:");
                cardNumber = sc.nextLine();
                System.out.println("Enter Card Type:");
                cardType = sc.nextLine();
                System.out.println("Enter Expiry Date (YYYY-MM-DD):");
                expiryDate = sc.nextLine();
            }

            donationsJson.append(String.format(
                "{\"Date\":\"%s\",\"Amount\":%.2f,\"Donation_type\":\"%s\",\"Campaign_name\":\"%s\","
                + "\"Cheque_No\":\"%s\",\"Card_Number\":\"%s\",\"Card_type\":\"%s\",\"Expiry_date\":\"%s\"}",
                date, amount, donationType, campaignName, chequeNo, cardNumber, cardType, expiryDate));

            if (i < numDonations - 1) {
                donationsJson.append(",");
            }
        }
        donationsJson.append("]");

        // Execute the stored procedure with the collected data
        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call AddNewDonorWithDonations(?, ?, ?, ?, ?, ?, ?, ?, ?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                // Set personal and donation details for the donor
                stmt.setString(1, ssn);
                stmt.setString(2, name);
                stmt.setString(3, gender);
                stmt.setString(4, profession);
                stmt.setString(5, mailingAddress);
                stmt.setString(6, emailAddress);
                stmt.setString(7, phoneNumber);
                stmt.setBoolean(8, mailingList);
                stmt.setBoolean(9, anonymous);
                stmt.setString(10, donationsJson.toString());
                stmt.execute();
                System.out.println("Donor and donations added successfully.");
            }
        } catch (SQLIntegrityConstraintViolationException e) {
            System.out.println("Error: A constraint violation occurred. Ensure the data is valid.");
        } catch (SQLException e) {
            e.printStackTrace();
            System.out.println("An error occurred while adding the donor and donations.");
        }
    }


    // Option 8: Retrieve the doctor's name and phone number of a client
    public static void get_Doctor_details() throws SQLException {
        System.out.println("Enter Client SSN:");
        sc.nextLine(); // Consume newline
        String clientSSN = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call GetDoctorInfo(?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, clientSSN);
                try (ResultSet rs = stmt.executeQuery()) {
                    if (rs.next()) {
                        String doctorName = rs.getString("Doctor_name");
                        String doctorPhone = rs.getString("Doctor_Phone_No");
                        System.out.println("Doctor Name: " + doctorName);
                        System.out.println("Doctor Phone Number: " + doctorPhone);
                    } else {
                        System.out.println("No doctor information found for the given client SSN.");
                    }
                }
            }
        }
    }

    // Option 9: Retrieve total expenses charged by each employee
    public static void get_Total_Expenses() throws SQLException {
        System.out.println("Enter Start Date (YYYY-MM-DD):");
        sc.nextLine(); // Consume newline
        String startDate = sc.nextLine();
        System.out.println("Enter End Date (YYYY-MM-DD):");
        String endDate = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call GetTotalExpenses(?, ?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setDate(1, Date.valueOf(startDate));
                stmt.setDate(2, Date.valueOf(endDate));
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Employee SSN | Total Expenses");
                    while (rs.next()) {
                        String employeeSSN = rs.getString("Employee_SSN");
                        double totalExpenses = rs.getDouble("Total_Expenses");
                        System.out.println(employeeSSN + " | " + totalExpenses);
                    }
                }
            }
        }
    }

    // Option 10: Retrieve volunteers in teams supporting a particular client
    public static void get_Volunteers_list() throws SQLException {
        System.out.println("Enter Client SSN:");
        sc.nextLine(); // Consume newline
        String clientSSN = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call GetVolunteersForClient(?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setString(1, clientSSN);
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Volunteer Name | Volunteer SSN");
                    while (rs.next()) {
                        String name = rs.getString("Name");
                        String ssn = rs.getString("SSN");
                        System.out.println(name + " | " + ssn);
                    }
                }
            }
        }
    }

    // Option 11: Retrieve teams founded after a particular date
    public static void get_Teams_list() throws SQLException {
        System.out.println("Enter Date (YYYY-MM-DD):");
        sc.nextLine(); // Consume newline
        String date = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call GetTeamsFoundedAfter(?)}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.setDate(1, Date.valueOf(date));
                try (ResultSet rs = stmt.executeQuery()) {
                    System.out.println("Team Names:");
                    while (rs.next()) {
                        String teamName = rs.getString("Name");
                        System.out.println(teamName);
                    }
                }
            }
        }
    }

    // Option 12: Retrieve all people and their emergency contact information
    public static void get_All_People_details() throws SQLException {
        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call GetAllPeopleAndEmergencyContacts}";
            try (CallableStatement stmt = connection.prepareCall(sql);
                 ResultSet rs = stmt.executeQuery()) {
                System.out.println("Name | SSN | Mailing Address | Email | Phone | Emergency Contact Name | Emergency Contact Phone | Relation");
                while (rs.next()) {
                    String name = rs.getString("Name");
                    String ssn = rs.getString("SSN");
                    String address = rs.getString("Mailing_Address");
                    String email = rs.getString("Email_Address");
                    String phone = rs.getString("Phone_Number");
                    String emergencyName = rs.getString("Emergency_Contact_Name");
                    String emergencyPhone = rs.getString("Emergency_Contact_Phone");
                    String relation = rs.getString("Relation");
                    System.out.println(name + " | " + ssn + " | " + address + " | " + email + " | " + phone + " | " + emergencyName + " | " + emergencyPhone + " | " + relation);
                }
            }
        }
    }

    // Option 13: Retrieve donors who are also employees
    public static void get_Employee_Donors() throws SQLException {
        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call GetEmployeeDonors}";
            try (CallableStatement stmt = connection.prepareCall(sql);
                 ResultSet rs = stmt.executeQuery()) {
                System.out.println("Name | SSN | Anonymous | Total Donated");
                while (rs.next()) {
                    String name = rs.getString("Name");
                    String ssn = rs.getString("SSN");
                    boolean anonymous = rs.getBoolean("Anonymous");
                    double totalDonated = rs.getDouble("Total_Donated");
                    System.out.println(name + " | " + ssn + " | " + anonymous + " | " + totalDonated);
                }
            }
        }
    }

    // Option 14: Increase salary by 10% for employees reported by multiple teams
    public static void increase_Salary() throws SQLException {
        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call IncreaseSalaryForMultiTeamEmployees}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.execute();
                System.out.println("Salaries updated successfully.");
            }
        }
    }

    // Option 15: Delete clients without health insurance and low transportation importance
    public static void delete_Clients_With_no_Health_Insurance() throws SQLException {
        try (Connection connection = DriverManager.getConnection(URL)) {
            String sql = "{call DeleteClientsWithoutHealthInsurance}";
            try (CallableStatement stmt = connection.prepareCall(sql)) {
                stmt.execute();
                System.out.println("Clients deleted successfully.");
            }
        }
    }

    // Option 16: Import teams from a file
    public static void import_Teams_From_File() throws SQLException, IOException {
        System.out.println("Please enter the input file name:");
        sc.nextLine(); // Consume newline
        String fileName = sc.nextLine();

        try (BufferedReader br = new BufferedReader(new FileReader(fileName));
             Connection connection = DriverManager.getConnection(URL)) {

            String line;
            while ((line = br.readLine()) != null) {
                String[] teamData = line.split(","); // Assume data is comma-separated
                String teamName = teamData[0].trim();
                String teamType = teamData[1].trim();
                Date dateFormed = Date.valueOf(teamData[2].trim());

                String sql = "{call AddNewTeam(?, ?, ?)}";
                try (CallableStatement stmt = connection.prepareCall(sql)) {
                    stmt.setString(1, teamName);
                    stmt.setString(2, teamType);
                    stmt.setDate(3, dateFormed);
                    stmt.execute();
                    System.out.println("Inserted team: " + teamName);
                }
            }
        }
    }

    // Option 17: Export mailing list to a file
    public static void export_Mailing_List() throws SQLException, IOException {
        System.out.println("Please enter the output file name:");
        sc.nextLine(); // Consume newline
        String fileName = sc.nextLine();

        try (Connection connection = DriverManager.getConnection(URL);
             PrintWriter pw = new PrintWriter(new FileWriter(fileName))) {

            String sql = "SELECT Name, Mailing_Address FROM People WHERE Mailing_List = 1";
            try (Statement stmt = connection.createStatement();
                 ResultSet rs = stmt.executeQuery(sql)) {

                while (rs.next()) {
                    String name = rs.getString("Name");
                    String address = rs.getString("Mailing_Address");
                    pw.println(name + ", " + address);
                }
                System.out.println("Mailing list exported to " + fileName);
            }
        }
    }
}
