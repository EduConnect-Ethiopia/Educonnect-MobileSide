import '../../core/constants/backend_enum_values.dart';
import '../../domain/entities/course.dart';

List<Course> mockRecommendedCourses() {
  return const [
    Course(
      id: 'mock-digital-literacy',
      title: 'Digital Literacy Essentials',
      description: 'Build confidence with everyday digital tools.',
      category: 'Technology',
      mode: BackendEnumValues.modeSelfPaced,
      status: BackendEnumValues.courseStatusPublished,
      price: 0,
      instructor: 'EduConnect Academy',
    ),
    Course(
      id: 'mock-business-basics',
      title: 'Small Business Basics',
      description: 'Plan, price, and manage a growing local business.',
      category: 'Business',
      mode: BackendEnumValues.modeInstructorLed,
      status: BackendEnumValues.courseStatusPublished,
      price: 450,
      instructor: 'EduConnect Academy',
    ),
    Course(
      id: 'mock-english-workplace',
      title: 'English for the Workplace',
      description: 'Practice clear communication for interviews and teams.',
      category: 'Language',
      mode: BackendEnumValues.modeSelfPaced,
      status: BackendEnumValues.courseStatusPublished,
      price: 300,
      instructor: 'EduConnect Academy',
    ),
  ];
}
