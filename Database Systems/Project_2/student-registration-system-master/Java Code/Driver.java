//package demo;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.sql.CallableStatement;
import java.sql.Connection;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.sql.Types;
import oracle.jdbc.OracleCallableStatement;
import oracle.jdbc.OracleTypes;
import oracle.jdbc.pool.OracleDataSource;

public class Driver {
	public static void main(String args[]) throws SQLException
	{
		try
		{
			int choice;
			OracleDataSource ds = new oracle.jdbc.pool.OracleDataSource();
		    ds.setURL("jdbc:oracle:thin:@//localhost:1522/oracle");
		    Connection conn = ds.getConnection("SYSTEM", "Saurabh123");
//		    String createTable = "create table temp (pre_dept_code varchar2(4),pre_course_no number(3))";
//			Statement stmt1 = conn.createStatement(); 
//			stmt1.executeQuery(createTable);
		    while(true)
		    {
		    	 printMenu(0);
		    	 choice = getChoice(9);
		    	 switch(choice)
		    	 {
			    	 case 1:
			    	 {
			    		 printMenu(1);
			    		 choice = getChoice(7);
			    		 printTableData(choice,conn);
			    		 break;
			    	 }
			    	 case 2:
			    	 {
			    		 InsertStudentRecord(conn);
			    		 break;
			    	 }
			    	 case 3:
			    	 {
			    		 getStudentInfo(conn);
			    		 break;
			    	 }
			    	 case 4:
			    	 {
			    		 getPrerequisites(conn);
			    		 break;
			    	 }
			    	 case 5:
			    	 {
			    		 getClassInfo(conn);
			    		 break;
			    	 }
			    	 case 6:
			    	 {
			    		 enrollStudent(conn);
			    		 break;
			    	 }
			    	 case 7:
			    	 {
			    		 dropEnrollment(conn);
			    		 break;
			    	 }
			    	 case 8:
			    	 {
			    		 deleteStudent(conn);
			    		 break;
			    	 }
			    	 case 9:
			    	 {
			    		 System.exit(1);
			    		 break;
			    	 }
		    	 }
		    	 
		    }
		}
		catch (Exception e) {
			e.printStackTrace();
			System.exit(1);
		}
	}
	public static void deleteStudent(Connection conn) {
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Student ID: ");
			String sid = br.readLine();
			CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.delete_student(?,?); END;");
			stmt.setString(1,sid);
			stmt.registerOutParameter(2, Types.INTEGER);
			stmt.execute();
			int status = stmt.getInt(2);
			switch (status) 
			{
				case 1:
				{
					System.out.println("Student "+sid+" deleted from database.");
					break;
				}
				case 2:
				{
					System.out.println("The sid is invalid");
					break;
				}
			}
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.exit(1);
		}
	}
	public static void dropEnrollment(Connection conn) {
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Student ID: ");
			String sid = br.readLine();
			System.out.println("Enter Class ID: ");
			String classid = br.readLine();
			CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.drop_enrollment(?,?,?,?,?); END;");
			stmt.setString(1,sid);
			stmt.setString(2,classid);
			stmt.registerOutParameter(3, Types.INTEGER);
			stmt.registerOutParameter(4, Types.INTEGER);
			stmt.registerOutParameter(5, Types.INTEGER);
			stmt.execute();
			int status = stmt.getInt(3);
			int last_class = stmt.getInt(4);
			int last_student = stmt.getInt(5);
			switch(status)
			{
				case 1:
				{
					System.out.println("Student "+sid+" is Dropped from class "+ classid);
					if(last_class==1)
					{
						System.out.println("This student is not enrolled in any classes");
					}
					if(last_student==1)
					{
						System.out.println("The class now has no students.");
					}
					break;
				}
				case 2:
				{
					System.out.println("The drop is not permitted because another class uses it as a prerequisite.");
					break;
				}
				case 3:
				{
					System.out.println("The student is not enrolled in the class");
					break;
				}
				case 4:
				{
					System.out.println("The classid is invalid.");
					break;
				}
				case 5:
				{
					System.out.println("The sid is invalid");
					break;
				}
			}
			
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.exit(1);
		}
	}
	public static void enrollStudent(Connection conn) {
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Student ID: ");
			String sid = br.readLine();
			System.out.println("Enter Class ID: ");
			String classid = br.readLine();
			CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.enrollment_student(?,?,?,?); END;");
			stmt.setString(1,sid);
			stmt.setString(2,classid);
			stmt.registerOutParameter(3, Types.INTEGER);
			stmt.registerOutParameter(4, Types.INTEGER);
			stmt.execute();
			int status = stmt.getInt(3);
			int count = stmt.getInt(4);
			switch(status)
			{
				case 1:
				{
					System.out.println(sid+" is Enrolled in class "+classid);
					if(count == 2)
					{
						System.out.println("You are overloaded");
					}
					break;
				}
				case 2:
				{
					System.out.println("Prerequisite courses have not been completed.");
					break;
				}
				case 3:
				{
					System.out.println("Students cannot be enrolled in more than three classes in the same semester.");
					break;
				}
				case 4:
				{
					System.out.println("The student is already in the class.");
					break;
				}
				case 5:
				{
					System.out.println("The class is closed.");
					break;
				}
				case 6:
				{
					System.out.println("The classid is invalid");
					break;
				}
				case 7:
				{
					System.out.println("The sid is invalid");
					break;
				}
			}
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.exit(1);
		}
		
		
	}
	public static void getPrerequisites(Connection conn) {	
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Enter Dept Code: ");
			String dept_code = br.readLine();
			System.out.println("Enter Course No: ");
			String course_no = br.readLine();
			
			
			
			
			
			CallableStatement cs = conn.prepareCall("begin databaseproject.get_prerequisites(?,?,?); end;");
			cs.setString(1,dept_code);
			cs.setInt(2, Integer.parseInt(course_no));
			cs.registerOutParameter(3,OracleTypes.CURSOR);
			cs.execute();
			
			ResultSet preRequistes = ((OracleCallableStatement)cs).getCursor(3);
			if(preRequistes.getFetchSize() == 0)
			{
				System.out.println("Course "+dept_code+course_no+" does not have any Prerequistes");
			}
			else
			{
				System.out.println("Prerequisite Courses for "+dept_code+course_no+": ");
				//System.out.format("%-4s\t%-3s","dept_code","course_no");
				//System.out.println("\n------------------------");
				while(preRequistes.next())
				{
					//System.out.format("%-4s\t\t%-3d\n",preRequistes.getString(1),preRequistes.getInt(2));
					System.out.println(preRequistes.getString(1)+preRequistes.getInt(2));
				}
			}
			//preRequistes.close();
			//cs.close();
			//stmt.executeQuery(dropTable);
			//stmt.close();
			//stmt1.close();
			String truncateTable = "TRUNCATE table temp";	
			Statement stmt = conn.createStatement();
			stmt.executeQuery(truncateTable);
		}
		catch (Exception e) 
		{
			e.printStackTrace();
			System.exit(1);
		}
	}
	public static void printTableData(int tableChoice, Connection conn)
	{
		switch(tableChoice)
		{
			case 1:
			{
				try 
				{
					CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.show_students(?); END;");
					stmt.registerOutParameter(1, OracleTypes.CURSOR); //REF CURSOR
				      stmt.execute();
				      ResultSet rs = ((OracleCallableStatement)stmt).getCursor(1);
				      
				      while (rs.next()) 
				      {
				    	  System.out.format("%-4s --> %-15s --> %-15s --> %-10s --> %.2f --> %-20s\n",
				    			  rs.getString(1), rs.getString(2),rs.getString(3),rs.getString(4),rs.getDouble(5),rs.getString(6));
				      }
				      rs.close();
				} 
				catch (SQLException e) 
				{
					e.printStackTrace();
					System.exit(1);
				}
				break;
			}
			case 2:
			{
				try
				{
					CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.show_courses(?); END;");
					stmt.registerOutParameter(1, OracleTypes.CURSOR); //REF CURSOR
				      stmt.execute();
				      ResultSet rs = ((OracleCallableStatement)stmt).getCursor(1);
				      while (rs.next()) 
				      {
				    	  System.out.format("%-4s --> %-3d --> %-20s\n",
				    			  rs.getString(1), rs.getInt(2),rs.getString(3));
				      }
				      rs.close();
				      stmt.close();
				}
				catch (SQLException e) 
				{
					e.printStackTrace();
					System.exit(1);
				}
				break;
			}
			case 3:
			{
				try
				{
					CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.show_classes(?); END;");
					stmt.registerOutParameter(1, OracleTypes.CURSOR); //REF CURSOR
				      stmt.execute();
				      ResultSet rs = ((OracleCallableStatement)stmt).getCursor(1);
				      while (rs.next()) 
				      {
				    	  System.out.format("%-5s --> %-4s --> %-3d --> %-2d --> %-4d --> %-6s --> %-3d --> %-3d\n",
				    			  rs.getString(1), rs.getString(2),rs.getInt(3),rs.getInt(4),rs.getInt(5),rs.getString(6),rs.getInt(7),rs.getInt(8));
				      }
				      rs.close();
				}
				catch (SQLException e) 
				{
					e.printStackTrace();
					System.exit(1);
				}
				break;
			}
			case 4:
			{
				try
				{
					CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.show_prerequisites(?); END;");
					stmt.registerOutParameter(1, OracleTypes.CURSOR); //REF CURSOR
				      stmt.execute();
				      ResultSet rs = ((OracleCallableStatement)stmt).getCursor(1);
				      while (rs.next()) 
				      {
				    	  System.out.format("%-4s --> %-3d --> %-4s --> %-3d\n",
				    			  rs.getString(1), rs.getInt(2), rs.getString(3),rs.getInt(4));
				      }
				      rs.close();
				}
				catch (SQLException e) 
				{
					e.printStackTrace();
					System.exit(1);
				}
				break;
			}
			case 5:
			{
				try
				{
					CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.show_enrollments(?); END;");
					stmt.registerOutParameter(1, OracleTypes.CURSOR); //REF CURSOR
				      stmt.execute();
				      ResultSet rs = ((OracleCallableStatement)stmt).getCursor(1);
				      while (rs.next()) 
				      {
				    	  System.out.format("%-5s --> %-4s --> %-1s\n",
				    			  rs.getString(1), rs.getString(2),rs.getString(3));
				      }
				      rs.close();
				}
				catch (SQLException e) 
				{
					e.printStackTrace();
					System.exit(1);
				}
				break;
			}
			case 6:
			{
				try
				{
					CallableStatement stmt = conn.prepareCall("BEGIN databaseproject.show_logs(?); END;");
					stmt.registerOutParameter(1, OracleTypes.CURSOR); //REF CURSOR
				      stmt.execute();
				      ResultSet rs = ((OracleCallableStatement)stmt).getCursor(1);
				      while (rs.next()) 
				      {
				    	  System.out.format("%-4d --> %-10s --> %-10s --> %-15s --> %-6s --> %-14s\n",
				    			  rs.getInt(1), rs.getString(2), rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6));
				      }
				      rs.close();
				}
				catch (SQLException e) 
				{
					e.printStackTrace();
					System.exit(1);
				}
				break;	
			}
			case 7:
			{
				printMenu(0);
				break;
			}
		}
	}
	public static int getChoice(int screen)
	{
		int choice = 0;
		try
		{
			BufferedReader input_reader = new BufferedReader(new InputStreamReader(System.in));
			do
			{
				System.out.println("Enter Choice");
				choice = Integer.parseInt(input_reader.readLine());
			}while(choice < 1 || choice > screen);
		}
		catch (Exception e) {
			System.out.println("getChoice Exeption");
			System.exit(1);
		}
		return choice;
	}
	public static void printMenu(int screen)
	{
		switch(screen)
		{
			case 0:
			{
				System.out.println();
				System.out.println("*****Main Menu*****");
				System.out.println("1.View Table Data:");//#2
				System.out.println("2.Add Student:");//#3
				System.out.println("3.View Studnet info:");//#4
				System.out.println("4.View Course Prerequisites:");//#5
				System.out.println("5.View Class Info");//#6
				System.out.println("6.Enroll a Student in Class:");//#7
				System.out.println("7.Drop a Student from Class:");//#8
				System.out.println("8.Delete a Student:");//#9
				System.out.println("9.Exit");
				break;
			}
			case 1:
			{
				System.out.println();
				System.out.println("***Select Table***");
				System.out.println("1.Students\n"
						+ "2.Courses\n"
						+ "3.Classes\n"
						+ "4.Prerequisites\n"
						+ "5.Enrollments\n"
						+ "6.Logs\n"
						+ "7.Back to Main Menu");
				break;
			}
		}
	}
	public static void getClassInfo(Connection conn)
	{
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Enter Classid: ");
			String classid = br.readLine();
			CallableStatement cs = conn.prepareCall("begin databaseproject.get_class_info(:1,:2,:3); end;");
			cs.setString(1,classid);
			cs.registerOutParameter(2,OracleTypes.CURSOR);
			cs.registerOutParameter(3,OracleTypes.CURSOR);
			cs.execute();
			ResultSet classInfo = ((OracleCallableStatement)cs).getCursor(2);
			ResultSet students = ((OracleCallableStatement)cs).getCursor(3);
			if(classInfo.getFetchSize() == 0)
			{
				System.out.println("The cid is invalid");
			}
			else
			{
				classInfo.next();
				System.out.println("Class ID: "+classInfo.getString(1));
				System.out.println("Title: "+classInfo.getString(2));
				System.out.println("Semester: "+classInfo.getString(3));
				System.out.println("Year: "+classInfo.getInt(4));
				if(students.getFetchSize() == 0)
				{
					System.out.println("No student is enrolled in the class.");
				}
				else
				{
					System.out.println("Enrolled Students: ");
					System.out.format("%-4s --> %-15s\n------------------------\n",
							"SID","Lastname");
					while(students.next())
					{
						System.out.format("%-4s --> %-15s\n",
								students.getString(1),students.getString(2));
					}
				}
			}
		}
		catch (Exception e) 
		{
			System.err.println("Exception in get Student Info.");
			e.printStackTrace();
			System.exit(1);
		}
	}
	public static void getStudentInfo(Connection conn)
	{
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Enter Sid: ");
			String sid = br.readLine();
			CallableStatement cs = conn.prepareCall("begin databaseproject.get_student_info(:1,:2,:3); end;");
			cs.setString(1,sid);
			cs.registerOutParameter(2,OracleTypes.CURSOR);
			cs.registerOutParameter(3,OracleTypes.CURSOR);
			cs.execute();
			ResultSet student = ((OracleCallableStatement)cs).getCursor(2);
			ResultSet classes = ((OracleCallableStatement)cs).getCursor(3);
			if(student.getFetchSize() == 0)
			{
				System.out.println("The SID is invalid");
			}
			else
			{
				student.next();
				System.out.println("SID: "+student.getString(1));
				System.out.println("Lastname: "+student.getString(2));
				System.out.println("Status: "+student.getString(3));
				if(classes.getFetchSize() == 0)
				{
					System.out.println("The student has not taken any course");
				}
				else
				{
					System.out.println("Enrolled Classes: ");
					while(classes.next())
					{
						System.out.format("%-5s --> %-7s --> %-20s --> %-4d --> %-6s\n",
								classes.getString(1),classes.getString(2),classes.getString(3),classes.getInt(4),classes.getString(5));
					}
				}
			}
		}
		catch (Exception e) 
		{
			System.err.println("Exception in get Student Info.");
			e.printStackTrace();
			System.exit(1);
		}
	}
	public static void InsertStudentRecord(Connection conn)
	{
		try
		{
			BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
			System.out.println("Enter Sid: ");
			String sid = br.readLine();
			System.out.println("Enter Firstname: ");
			String firstname = br.readLine();
			System.out.println("Enter Lastname: ");
			String lastname = br.readLine();
			System.out.println("Enter Status: ");
			String status = br.readLine();
			System.out.println("Enter GPA: ");
			Double gpa = Double.parseDouble(br.readLine());
			System.out.println("Enter Email ID: ");
			String email = br.readLine();
			CallableStatement cs = conn.prepareCall("begin databaseproject.insert_student(:1,:2,:3,:4,:5,:6,:7,:8); end;");
			cs.setString(1,sid);
			cs.setString(2,firstname);
			cs.setString(3,lastname);
			cs.setString(4,status);
			cs.setDouble(5, gpa);
			cs.setString(6,email);
			cs.registerOutParameter(7, Types.INTEGER);
			cs.registerOutParameter(8, Types.INTEGER);
			cs.executeQuery();

			int sid_validity = cs.getInt(7);
			int email_validity = cs.getInt(8);
			
			if(sid_validity==0)
			{
				if(email_validity==0)
				{
					System.out.println("Student Record Inserted Successfully.");
				}
				else
				{
					System.out.println("SID already Exists.");
				}
			}
			else
			{
				System.out.println("Email ID already Exists.");
			}
			
		}
		catch (Exception e) 
		{
			System.err.println("Exception in Insert Student.");
			e.printStackTrace();
			System.exit(1);
		}
	}
}
