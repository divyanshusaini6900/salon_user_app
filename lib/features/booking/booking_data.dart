import 'models.dart';

const stylists = <Stylist>[
  Stylist(name: 'Yoyo', level: 'Master Stylist'),
  Stylist(name: 'Ariana', level: 'Color Expert'),
  Stylist(name: 'Maya', level: 'Texture Specialist'),
  Stylist(name: 'Rhea', level: 'Senior Stylist'),
];

final services = <Service>[
  Service(
    id: 'cut',
    name: 'Signature Haircut',
    duration: Duration(minutes: 45),
    price: 799,
    rating: 4.9,
    category: 'Hair',
    description:
        'Precision haircut with a deep consultation, wash, and style. Ideal for refreshing your shape and keeping maintenance effortless.',
  ),
  Service(
    id: 'color',
    name: 'Luxe Color Blend',
    duration: Duration(hours: 2),
    price: 2199,
    rating: 4.8,
    category: 'Color',
    description:
        'Multi-dimensional color application with gloss finish. Includes toner, mask, and styling for a luminous finish.',
  ),
  Service(
    id: 'spa',
    name: 'Scalp Renewal Spa',
    duration: Duration(minutes: 60),
    price: 1299,
    rating: 4.7,
    category: 'Wellness',
    description:
        'Detoxifying scalp ritual with aromatic steam, massage, and hydration therapy for healthy roots.',
  ),
  Service(
    id: 'style',
    name: 'Event Styling',
    duration: Duration(minutes: 50),
    price: 999,
    rating: 4.8,
    category: 'Style',
    description:
        'Blowout, curls, or sleek styles customized for your event. Includes heat protection and finish spray.',
  ),
  Service(
    id: 'nails',
    name: 'Signature Manicure',
    duration: Duration(minutes: 40),
    price: 699,
    rating: 4.6,
    category: 'Nails',
    description:
        'Cuticle care, shaping, massage, and polish. Choose from seasonal palettes curated by our nail artists.',
  ),
];

final timeSlots = <String>[
  '09:00 AM',
  '09:30 AM',
  '10:00 AM',
  '11:30 AM',
  '12:00 PM',
  '02:00 PM',
  '03:00 PM',
  '04:30 PM',
  '05:00 PM',
  '06:30 PM',
];
