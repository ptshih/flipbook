//
//  CardIOCreditCardInfo.h
//  Copyright (c) 2011-2013 PayPal. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  CardIOCreditCardTypeUnknown = 0,  // deprecated; use CardIOCreditCardTypeUnrecognized or CardIOCreditCardTypeAmbiguous
  CardIOCreditCardTypeUnrecognized = 0,  // the card number does not correspond to any recognizable card type
  CardIOCreditCardTypeAmbiguous = 1,  // the card number corresponds to multiple card types (e.g. when only a few digits have been entered)
  CardIOCreditCardTypeAmex = '3',
  CardIOCreditCardTypeJCB = 'J',
  CardIOCreditCardTypeVisa = '4',
  CardIOCreditCardTypeMastercard = '5',
  CardIOCreditCardTypeDiscover = '6'
} CardIOCreditCardType;


@interface CardIOCreditCardInfo : NSObject<NSCopying>

@property(nonatomic, copy, readwrite) NSString *cardNumber;
@property(nonatomic, copy, readonly) NSString *redactedCardNumber; // card number with all but the last four digits obfuscated

// expiryMonth & expiryYear may be 0, if expiry information is not requested
@property(nonatomic, assign, readwrite) NSUInteger expiryMonth; // January == 1
@property(nonatomic, assign, readwrite) NSUInteger expiryYear; // the full four digit year

// cvv and/or zip may be nil, if not requested
@property(nonatomic, copy, readwrite) NSString *cvv;
@property(nonatomic, copy, readwrite) NSString *zip;

// was the card number scanned (as opposed to manually entered)?
@property(nonatomic, assign, readwrite) BOOL scanned;

// Derived from cardNumber.
// When provided by card.io, cardType will not be CardIOCreditCardTypeUnrecognized or CardIOCreditCardTypeAmbiguous.
@property(nonatomic, assign, readonly) CardIOCreditCardType cardType;

// Convenience method to return a card type string (e.g. "Visa", "AmEx", "JCB", "MasterCard", or "Discover") suitable for display.
// Currently English only.
+ (NSString *)displayStringForCardType:(CardIOCreditCardType)cardType;

// Returns a 36x25 credit card logo, at a resolution appropriate for the device
+ (UIImage *)logoForCardType:(CardIOCreditCardType)cardType;

@end
