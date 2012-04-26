::LIGHTWIRE_CURRENCIES = %w[USD CAD EUR GBP HKD AUD JPY SGD]

class Object
    def CURRENCY_OK?(curr)
        ::LIGHTWIRE_CURRENCIES.include?(curr)
    end
end
