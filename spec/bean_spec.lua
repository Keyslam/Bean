local Bean = require('bean.init')

describe('Bean', function()
    it('should have a description', function()
        assert.is_string(Bean._DESCRIPTION)
    end)

    it('should have a license', function()
        assert.is_string(Bean._LICENSE)
    end)
end)
