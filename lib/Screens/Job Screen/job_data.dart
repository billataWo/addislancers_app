class Job {
  final String title;
  final List<Specialization> specializations;

  Job({required this.title, required this.specializations});
}

class Specialization {
  final String name;
  final List<String> skills;

  Specialization({required this.name, required this.skills});
}

List<Job> jobs = [
  Job(
    title: "Web Developer",
    specializations: [
      Specialization(name: "Frontend Web Developer", skills: [
        "HTML",
        "CSS",
        "JavaScript",
        "React",
        "Angular",
        "Vue.js",
        "Bootstrap",
        "jQuery"
      ]),
      Specialization(name: "Backend Web Developer", skills: [
        "Node.js",
        "Express.js",
        "Django",
        "Ruby on Rails",
        "PHP",
        "ASP.NET",
        "SQL",
        "MongoDB"
      ]),
      Specialization(name: "Full Stack Web Developer", skills: [
        "HTML",
        "CSS",
        "JavaScript",
        "Node.js",
        "Express.js",
        "React",
        "Angular",
        "SQL",
        "MongoDB"
      ]),
    ],
  ),
  Job(
    title: "Mobile App Developer",
    specializations: [
      Specialization(name: "iOS Developer", skills: [
        "Swift",
        "Objective-C",
        "Xcode",
        "UIKit",
        "Core Data",
        "RESTful APIs"
      ]),
      Specialization(name: "Android Developer", skills: [
        "Java",
        "Kotlin",
        "Android Studio",
        "XML",
        "Jetpack",
        "Firebase",
        "RESTful APIs"
      ]),
      Specialization(name: "Cross-Platform Developer", skills: [
        "React Native",
        "Flutter",
        "Dart",
        "Xamarin",
        "JavaScript",
        "C#"
      ]),
    ],
  ),
  Job(
    title: "Data Scientist",
    specializations: [
      Specialization(name: "Machine Learning Engineer", skills: [
        "Python",
        "R",
        "TensorFlow",
        "PyTorch",
        "Scikit-learn",
        "Pandas",
        "NumPy",
        "SQL"
      ]),
      Specialization(name: "Data Analyst", skills: [
        "SQL",
        "Excel",
        "Python",
        "R",
        "Tableau",
        "Power BI",
        "Data Visualization"
      ]),
      Specialization(name: "Data Engineer", skills: [
        "SQL",
        "Python",
        "Java",
        "Hadoop",
        "Spark",
        "Kafka",
        "ETL Processes",
        "Data Warehousing"
      ]),
    ],
  ),
  Job(
    title: "DevOps Engineer",
    specializations: [
      Specialization(name: "Cloud Engineer", skills: [
        "AWS",
        "Azure",
        "Google Cloud Platform",
        "Docker",
        "Kubernetes",
        "Terraform",
        "Ansible"
      ]),
      Specialization(name: "Site Reliability Engineer (SRE)", skills: [
        "Python",
        "Go",
        "Linux",
        "Prometheus",
        "Grafana",
        "CI/CD Pipelines",
        "Jenkins",
        "Monitoring Tools"
      ]),
    ],
  ),
  Job(
    title: "Cybersecurity Specialist",
    specializations: [
      Specialization(name: "Penetration Tester", skills: [
        "Python",
        "Bash",
        "Kali Linux",
        "Metasploit",
        "Nmap",
        "Burp Suite",
        "Wireshark"
      ]),
      Specialization(name: "Security Analyst", skills: [
        "SIEM Tools",
        "IDS/IPS",
        "Firewalls",
        "Incident Response",
        "Threat Hunting",
        "Vulnerability Management"
      ]),
      Specialization(name: "Security Engineer", skills: [
        "Network Security",
        "Encryption",
        "IDS/IPS",
        "Firewalls",
        "SIEM Tools",
        "Security Protocols"
      ]),
    ],
  ),
  Job(
    title: "Project Manager",
    specializations: [
      Specialization(name: "Agile Project Manager", skills: [
        "Scrum",
        "Kanban",
        "Agile Methodologies",
        "JIRA",
        "Trello",
        "Team Leadership",
        "Communication"
      ]),
      Specialization(name: "IT Project Manager", skills: [
        "ITIL",
        "PMP",
        "PRINCE2",
        "MS Project",
        "Risk Management",
        "Stakeholder Management"
      ]),
    ],
  ),
  Job(
    title: "UX/UI Designer",
    specializations: [
      Specialization(name: "UX Designer", skills: [
        "User Research",
        "Wireframing",
        "Prototyping",
        "Usability Testing",
        "Figma",
        "Sketch",
        "Adobe XD"
      ]),
      Specialization(name: "UI Designer", skills: [
        "Visual Design",
        "Color Theory",
        "Typography",
        "Sketch",
        "Figma",
        "Adobe XD",
        "CSS"
      ]),
    ],
  ),
  Job(
    title: "Software Developer",
    specializations: [
      Specialization(
          name: "Frontend Developer",
          skills: ["HTML", "CSS", "JavaScript", "React", "Angular", "Vue.js"]),
      Specialization(name: "Backend Developer", skills: [
        "Java",
        "Python",
        "C#",
        "SQL",
        "NoSQL",
        "REST APIs",
        "Microservices"
      ]),
      Specialization(name: "Full Stack Developer", skills: [
        "HTML",
        "CSS",
        "JavaScript",
        "Node.js",
        "React",
        "SQL",
        "NoSQL",
        "REST APIs"
      ]),
    ],
  ),
  Job(
    title: "Systems Administrator",
    specializations: [
      Specialization(name: "Network Administrator", skills: [
        "TCP/IP",
        "DNS",
        "DHCP",
        "Cisco",
        "Juniper",
        "Network Monitoring",
        "Firewalls"
      ]),
      Specialization(name: "Database Administrator", skills: [
        "SQL",
        "Oracle",
        "MySQL",
        "PostgreSQL",
        "Performance Tuning",
        "Backup and Recovery",
        "Data Security"
      ]),
      Specialization(name: "Windows/Linux Administrator", skills: [
        "Active Directory",
        "PowerShell",
        "Bash",
        "System Monitoring",
        "Virtualization",
        "Cloud Services"
      ]),
    ],
  ),
  Job(
    title: "Content Writer",
    specializations: [
      Specialization(name: "Technical Writer", skills: [
        "Technical Writing",
        "Documentation",
        "API Documentation",
        "Content Management Systems (CMS)"
      ]),
      Specialization(name: "Copywriter", skills: [
        "SEO",
        "Marketing",
        "Brand Voice",
        "Content Strategy",
        "Social Media"
      ]),
      Specialization(name: "Blog Writer", skills: [
        "SEO",
        "WordPress",
        "Content Creation",
        "Research",
        "Editing"
      ]),
    ],
  ),
  Job(
    title: "Digital Marketing Specialist",
    specializations: [
      Specialization(name: "SEO Specialist", skills: [
        "Keyword Research",
        "On-page SEO",
        "Off-page SEO",
        "Google Analytics",
        "Link Building",
        "Content Optimization"
      ]),
      Specialization(name: "Social Media Manager", skills: [
        "Social Media Strategy",
        "Content Creation",
        "Analytics",
        "Advertising (Facebook, Instagram, LinkedIn)",
        "Community Management"
      ]),
      Specialization(name: "PPC Specialist", skills: [
        "Google Ads",
        "Bing Ads",
        "Keyword Research",
        "Campaign Management",
        "A/B Testing",
        "Analytics"
      ]),
    ],
  ),
  Job(
    title: "Graphic Designer",
    specializations: [
      Specialization(name: "Print Designer", skills: [
        "Adobe InDesign",
        "Adobe Illustrator",
        "Adobe Photoshop",
        "Typography",
        "Layout Design",
        "Branding"
      ]),
      Specialization(name: "Digital Designer", skills: [
        "Adobe XD",
        "Sketch",
        "Figma",
        "Web Design",
        "Mobile App Design",
        "User Interface Design"
      ]),
      Specialization(name: "Motion Graphics Designer", skills: [
        "Adobe After Effects",
        "Adobe Premiere Pro",
        "Animation",
        "Video Editing",
        "Visual Effects"
      ]),
    ],
  ),
  Job(
    title: "Customer Support Specialist",
    specializations: [
      Specialization(name: "Technical Support Specialist", skills: [
        "Troubleshooting",
        "CRM Software",
        "Remote Desktop Tools",
        "Customer Service",
        "Technical Knowledge"
      ]),
      Specialization(name: "Customer Success Manager", skills: [
        "Account Management",
        "CRM Software",
        "Customer Retention",
        "Onboarding",
        "Upselling"
      ]),
      Specialization(name: "Chat Support Specialist", skills: [
        "Live Chat Tools",
        "Multitasking",
        "Problem Solving",
        "Customer Service",
        "Communication"
      ]),
    ],
  ),
  Job(
    title: "Virtual Assistant",
    specializations: [
      Specialization(name: "Administrative Assistant", skills: [
        "Email Management",
        "Calendar Management",
        "Data Entry",
        "MS Office",
        "Communication",
        "Organization"
      ]),
      Specialization(name: "Personal Assistant", skills: [
        "Travel Arrangements",
        "Appointment Scheduling",
        "Personal Errands",
        "Confidentiality",
        "Time Management"
      ]),
      Specialization(name: "E-commerce Assistant", skills: [
        "Order Processing",
        "Inventory Management",
        "Customer Service",
        "Product Listings",
        "Shopify",
        "WooCommerce"
      ]),
    ],
  ),
  Job(
    title: "Translator/Interpreter",
    specializations: [
      Specialization(name: "Document Translator", skills: [
        "Bilingual/Multilingual",
        "Grammar",
        "Contextual Understanding",
        "Translation Software",
        "Proofreading"
      ]),
      Specialization(name: "Medical Interpreter", skills: [
        "Medical Terminology",
        "Bilingual/Multilingual",
        "Confidentiality",
        "Communication",
        "Cultural Sensitivity"
      ]),
      Specialization(name: "Legal Translator", skills: [
        "Legal Terminology",
        "Bilingual/Multilingual",
        "Attention to Detail",
        "Confidentiality",
        "Proofreading"
      ]),
    ],
  ),
  Job(
    title: "Online Educator/Instructor",
    specializations: [
      Specialization(name: "ESL Teacher", skills: [
        "English Proficiency",
        "Teaching Methods",
        "Lesson Planning",
        "Classroom Management",
        "Online Teaching Tools"
      ]),
      Specialization(name: "Subject-Specific Tutor", skills: [
        "Subject Knowledge (Math, Science, History, etc.)",
        "Teaching Methods",
        "Curriculum Development",
        "Communication"
      ]),
      Specialization(name: "Corporate Trainer", skills: [
        "Training Programs",
        "Presentation Skills",
        "Industry Knowledge",
        "Communication",
        "E-learning Tools"
      ]),
    ],
  ),
  Job(
    title: "Social Scientist",
    specializations: [
      Specialization(name: "Market Research Analyst", skills: [
        "Data Analysis",
        "Survey Design",
        "Statistics",
        "SPSS",
        "Market Trends",
        "Communication"
      ]),
      Specialization(name: "Sociologist", skills: [
        "Research Methods",
        "Data Collection",
        "Qualitative Analysis",
        "SPSS",
        "Social Theory",
        "Communication"
      ]),
      Specialization(name: "Psychologist", skills: [
        "Research Methods",
        "Data Analysis",
        "Clinical Knowledge",
        "SPSS",
        "Therapeutic Techniques",
        "Communication"
      ]),
    ],
  ),
];
