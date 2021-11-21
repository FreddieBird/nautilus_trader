# -------------------------------------------------------------------------------------------------
#  Copyright (C) 2015-2021 Nautech Systems Pty Ltd. All rights reserved.
#  https://nautechsystems.io
#
#  Licensed under the GNU Lesser General Public License Version 3.0 (the "License");
#  You may not use this file except in compliance with the License.
#  You may obtain a copy of the License at https://www.gnu.org/licenses/lgpl-3.0.en.html
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
# -------------------------------------------------------------------------------------------------

from cpython.datetime cimport date
from libc.stdint cimport int64_t

from decimal import Decimal

from nautilus_trader.core.correctness cimport Condition
from nautilus_trader.model.c_enums.asset_class cimport AssetClass
from nautilus_trader.model.c_enums.asset_class cimport AssetClassParser
from nautilus_trader.model.c_enums.asset_type cimport AssetType
from nautilus_trader.model.currency cimport Currency
from nautilus_trader.model.identifiers cimport InstrumentId
from nautilus_trader.model.identifiers cimport Symbol
from nautilus_trader.model.instruments.base cimport Instrument
from nautilus_trader.model.objects cimport Price
from nautilus_trader.model.objects cimport Quantity


cdef class Future(Instrument):
    """
    Represents a futures contract instrument.
    """

    def __init__(
        self,
        InstrumentId instrument_id not None,
        Symbol local_symbol not None,
        AssetClass asset_class,
        Currency currency not None,
        int price_precision,
        Price price_increment not None,
        Quantity multiplier,
        Quantity lot_size not None,
        str underlying,
        date expiry_date,
        int64_t ts_event,
        int64_t ts_init,
    ):
        """
        Initialize a new instance of the ``Future`` class.

        Parameters
        ----------
        instrument_id : InstrumentId
            The instrument ID.
        local_symbol : Symbol
            The local/native symbol on the exchange for the instrument.
        asset_class : AssetClass
            The futures contract asset class.
        currency : Currency
            The futures contract currency.
        price_precision : int
            The price decimal precision.
        price_increment : Decimal
            The minimum price increment (tick size).
        multiplier : Quantity
            The contract multiplier.
        lot_size : Quantity
            The rounded lot unit size (standard/board).
        underlying : str
            The underlying asset.
        expiry_date : date
            The contract expiry date.
        ts_event: int64
            The UNIX timestamp (nanoseconds) when the data event occurred.
        ts_init: int64
            The UNIX timestamp (nanoseconds) when the data object was initialized.

        Raises
        ------
        ValueError
            If `multiplier` is not positive (> 0).
        ValueError
            If `price_precision` is negative (< 0).
        ValueError
            If `tick_size` is not positive (> 0).
        ValueError
            If `lot_size` is not positive (> 0).

        """
        super().__init__(
            instrument_id=instrument_id,
            local_symbol=local_symbol,
            asset_class=asset_class,
            asset_type=AssetType.FUTURE,
            quote_currency=currency,
            is_inverse=False,
            price_precision=price_precision,
            size_precision=0,  # No fractional units
            price_increment=price_increment,
            size_increment=Quantity.from_int_c(1),
            multiplier=multiplier,
            lot_size=lot_size,
            max_quantity=None,
            min_quantity=Quantity.from_int_c(1),
            max_notional=None,
            min_notional=None,
            max_price=None,
            min_price=None,
            margin_init=Decimal(0),
            margin_maint=Decimal(0),
            maker_fee=Decimal(0),
            taker_fee=Decimal(0),
            ts_event=ts_event,
            ts_init=ts_init,
            info={},
        )
        self.underlying = underlying
        self.expiry_date = expiry_date

    @staticmethod
    cdef Future from_dict_c(dict values):
        Condition.not_none(values, "values")
        return Future(
            instrument_id=InstrumentId.from_str_c(values["id"]),
            local_symbol=Symbol(values["local_symbol"]),
            asset_class=AssetClassParser.from_str(values["asset_class"]),
            currency=Currency.from_str_c(values['currency']),
            price_precision=values['price_precision'],
            price_increment=Price.from_str(values['price_increment']),
            multiplier=Quantity.from_str(values['multiplier']),
            lot_size=Quantity.from_str(values['lot_size']),
            underlying=values['underlying'],
            expiry_date=date.fromisoformat(values['expiry_date']),
            ts_event=values['ts_event'],
            ts_init=values['ts_init'],
        )

    @staticmethod
    cdef dict to_dict_c(Future obj):
        Condition.not_none(obj, "obj")
        return {
            "type": "Equity",
            "id": obj.id.value,
            "local_symbol": obj.local_symbol.value,
            "asset_class": AssetClassParser.to_str(obj.asset_class),
            "currency": obj.quote_currency.code,
            "price_precision": obj.price_precision,
            "price_increment": str(obj.price_increment),
            "size_precision": obj.size_precision,
            "size_increment": str(obj.size_increment),
            "multiplier": str(obj.multiplier),
            "lot_size": str(obj.lot_size),
            "underlying": obj.underlying,
            "expiry_date": obj.expiry_date.isoformat(),
            "margin_init": str(obj.margin_init),
            "margin_maint": str(obj.margin_maint),
            "ts_event": obj.ts_event,
            "ts_init": obj.ts_init,
        }

    @staticmethod
    def from_dict(dict values) -> Instrument:
        """
        Return an instrument from the given initialization values.

        Parameters
        ----------
        values : dict[str, object]
            The values to initialize the instrument with.

        Returns
        -------
        Instrument

        """
        return Instrument.from_dict_c(values)

    @staticmethod
    def to_dict(Instrument obj):
        """
        Return a dictionary representation of this object.

        Returns
        -------
        dict[str, object]

        """
        return Instrument.to_dict_c(obj)